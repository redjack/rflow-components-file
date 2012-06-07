require 'eventmachine'
require 'rflow/component'

require 'digest/md5'

class RFlow
  module Components
    module File
      class OutputRawToFiles < RFlow::Component
        input_port :raw_port

        DEFAULT_CONFIG = {
          'directory_path'  => '/tmp/export',
          'file_name_prefix' => 'export', 
        }

        attr_accessor :config, :directory_path, :file_name_prefix
        
        def configure!(config)
          @config = DEFAULT_CONFIG.merge config
          @directory_path  = ::File.expand_path(@config['directory_path'])
          @file_name_prefix = @config['file_name_prefix']
          
          unless ::File.directory?(@directory_path)
            raise ArgumentError, "Invalid directory '#{@directory_path}'"
          end
          
          unless ::File.writable?(@directory_path)
            raise ArgumentError, "Unable to read from directory '#{@directory_path}'"
          end

          # TODO: more error checking of input config
        end

        def process_message(input_port, input_port_key, connection, message)
          return unless message.data_type_name == 'RFlow::Message::Data::Raw'

          RFlow.logger.debug "Outputting raw message to file"
          RFlow.logger.debug "Raw data is #{message.data.raw.bytesize} bytes with md5 #{Digest::MD5.hexdigest message.data.raw}"
          
          @output_file_entropy = 0
          begin
            final_output_file_name = output_file_name
            
            temp_output_file_path = ::File.join(directory_path, ".#{final_output_file_name}")
            final_output_file_path = ::File.join(directory_path, "#{final_output_file_name}")
            
            RFlow.logger.debug("before opening/writing file #{temp_output_file_path}")
            ::File.open(temp_output_file_path, ::File::CREAT|::File::EXCL|::File::RDWR, 0644) do |file|
              RFlow.logger.debug("locking file")
              file.flock(::File::LOCK_EX)
              RFlow.logger.debug("writing file")
              file.write(message.data.raw)
              RFlow.logger.debug("done writing file")
            end
            RFlow.logger.debug("after writing file #{temp_output_file_path}, renaming to #{final_output_file_path}")
            ::File.rename(temp_output_file_path, final_output_file_path)
            RFlow.logger.debug("after renaming file to #{final_output_file_path}")

          rescue Errno::EEXIST => e
            RFlow.logger.debug("file #{temp_output_file_path} exists, increasing entropy")
            retry
          end
          
          final_output_file_path
        end


        def output_file_name 
          "#{file_name_prefix}.#{current_timestamp}.#{output_file_entropy}"
        end

        def output_file_entropy
          @output_file_entropy += 1
          sprintf("%04d", @output_file_entropy)
        end
        
        def current_timestamp
          time = Time.now
          time.utc.strftime("%Y%m%d_%H%M%S.") + "%06d" % time.utc.usec
        end
        
      end
    end
  end
end
