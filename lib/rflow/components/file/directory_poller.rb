require 'eventmachine'
require 'rflow/component'

class RFlow
  module Components
    module File
      class DirectoryPoller < RFlow::Component
        output_port :file_port
        
        DEFAULT_CONFIG = {
          'directory_path'  => '/tmp/import',
          'file_name_glob'  => '*',
          'poll_interval'   => 1,
          'files_per_poll'  => 1,
          'remove_files'    => true,
        }

        attr_accessor :config, :poll_interval, :directory_path, :file_name_regex
        
        def configure!(config)
          @config = DEFAULT_CONFIG.merge config
          @directory_path  = ::File.expand_path(@config['directory_path'])
          @file_name_glob  = @config['file_name_glob']
          @poll_interval   = @config['poll_interval'].to_i
          @files_per_poll  = @config['files_per_poll'].to_i
          @remove_files    = @config['remove_files']  
          
          unless ::File.directory?(@directory_path)
            raise ArgumentError, "Invalid directory '#{@directory_path}'"
          end
          
          unless ::File.readable?(@directory_path)
            raise ArgumentError, "Unable to read from directory '#{@directory_path}'"
          end

          # TODO: more error checking of input config
        end

        def run!
          timer = EventMachine::PeriodicTimer.new(poll_interval) do
            RFlow.logger.debug "Polling for files in #{::File.join(@directory_path, @file_name_glob)}"
            # Sort by last modified, which will process the earliest
            # modified file first
            file_paths = Dir.glob(::File.join(@directory_path, @file_name_glob)).sort_by {|f| test(?M, f)}

            file_paths.first(@files_per_poll).each do |file_path|
              RFlow.logger.debug "Importing #{file_path}"
              ::File.open(file_path) do |file|
                file_message = RFlow::Message.new('RFlow::Message::Data::File')
                file_message.data.data_object = {
                  'path' => ::File.expand_path(file.path),
                  'size' => file.size,
                  'content' => file.read,
                  'creation_timestamp' => file.ctime,
                  'modification_timestamp' => file.mtime,
                  'access_timestamp' => file.atime,
                }
                file_port.send_message file_message
              end

              if @remove_files
                RFlow.logger.debug "Removing #{::File.join(@directory_path, file_path)}"
                ::File.delete file_path
              end
            end
          end
        end
        
      end
    end
  end
end
