require 'rflow/component'

require 'digest/md5'

class RFlow
  module Components
    module File
      class DirectoryWatcher < RFlow::Component
        output_port :file_port
        output_port :raw_port
        
        DEFAULT_CONFIG = {
          'directory_path'  => '/tmp/import',
          'file_name_glob'  => '*',
          'poll_interval'   => 1,
          'files_per_poll'  => 1,
          'remove_files'    => true,
        }

        attr_accessor :config, :poll_interval, :directory_path, :file_name_glob, :remove_files
        
        def configure!(config)
          @config = DEFAULT_CONFIG.merge config
          @directory_path  = ::File.expand_path(@config['directory_path'])
          @file_name_glob  = @config['file_name_glob']
          @poll_interval   = @config['poll_interval'].to_i
          @files_per_poll  = @config['files_per_poll'].to_i
          @remove_files    = to_boolean(@config['remove_files'])
          
          unless ::File.directory?(@directory_path)
            raise ArgumentError, "Invalid directory '#{@directory_path}'"
          end
          
          unless ::File.readable?(@directory_path)
            raise ArgumentError, "Unable to read from directory '#{@directory_path}'"
          end

          # TODO: more error checking of input config
        end


        # TODO: optimize sending of messages based on what is connected
        def run!
          timer = EventMachine::PeriodicTimer.new(poll_interval) do
            RFlow.logger.debug "Polling for files in #{::File.join(@directory_path, @file_name_glob)}"
            # Sort by last modified, which will process the earliest
            # modified file first
            file_paths = Dir.glob(::File.join(@directory_path, @file_name_glob)).sort_by {|f| test(?M, f)}

            file_paths.first(@files_per_poll).each do |file_path|
              RFlow.logger.debug "Importing #{file_path}"
              ::File.open(file_path, 'r:BINARY') do |file|
                file_content = file.read
                
                RFlow.logger.debug "read #{file_content.bytesize} bytes of #{file.size} in #{file.path}, md5 #{Digest::MD5.hexdigest(file_content)}"

                file_message = RFlow::Message.new('RFlow::Message::Data::File')

                file_message.data.path = ::File.expand_path(file.path)
                file_message.data.size = file.size
                file_message.data.content = file_content
                file_message.data.creation_timestamp = file.ctime
                file_message.data.modification_timestamp = file.mtime
                file_message.data.access_timestamp = file.atime
                
                file_port.send_message file_message

                raw_message = RFlow::Message.new('RFlow::Message::Data::Raw')
                raw_message.data.raw = file_content
                raw_port.send_message raw_message
              end

              if @remove_files
                RFlow.logger.debug "Removing #{::File.join(@directory_path, file_path)}"
                ::File.delete file_path
              end
            end
          end
        end

        def to_boolean(string)
          case string
          when /^true$/i, '1', true
            true
          when /^false/i, '0', false
            false
          else
            raise ArgumentError, "'#{string}' cannot be coerced to a boolean value"
          end
        end
        
      end
    end
  end
end
