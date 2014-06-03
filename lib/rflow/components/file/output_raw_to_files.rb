require 'eventmachine'
require 'rflow/component'
require 'digest/md5'

class RFlow
  module Components
    module File
      class OutputRawToFiles < RFlow::Component
        input_port :raw_port

        DEFAULT_CONFIG = {
          'directory_path'  => '/tmp',
          'file_name_prefix' => 'output.',
          'file_name_suffix' => '.out',
        }

        attr_accessor :config, :directory_path, :file_name_prefix, :file_name_suffix

        def configure!(config)
          @config = DEFAULT_CONFIG.merge config
          @directory_path  = ::File.expand_path(@config['directory_path'])
          @file_name_prefix = @config['file_name_prefix']
          @file_name_suffix = @config['file_name_suffix']

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

          @output_file_entropy = 1
          begin
            final_output_file_name = output_file_name

            temp_output_file_path = ::File.join(directory_path, ".#{final_output_file_name}")
            final_output_file_path = ::File.join(directory_path, "#{final_output_file_name}")

            RFlow.logger.debug { "#{self.class.name}##{__method__}: Outputting raw message to #{final_output_file_path} (via #{temp_output_file_path}) with #{message.data.raw.bytesize} bytes and md5 #{Digest::MD5.hexdigest message.data.raw}" }

            ::File.open(temp_output_file_path, ::File::CREAT|::File::EXCL|::File::RDWR, 0644, :external_encoding => 'BINARY') do |file|
              file.flock(::File::LOCK_EX)
              file.write(message.data.raw)
            end
            ::File.rename(temp_output_file_path, final_output_file_path)
            RFlow.logger.debug { "#{self.class.name}##{__method__}: Succesfully output raw message to #{final_output_file_path}" }
          rescue Errno::EEXIST => e
            RFlow.logger.debug { "#{self.class.name}##{__method__}: File #{temp_output_file_path} exists, increasing entropy" }
            @output_file_entropy += 1
            retry
          end

          final_output_file_path
        end

        private
        def output_file_name
          "#{file_name_prefix}.#{current_timestamp}.#{output_file_entropy_string}#{file_name_suffix}"
        end

        def output_file_entropy_string
          sprintf("%04d", @output_file_entropy || 1)
        end

        def current_timestamp
          time = Time.now
          time.utc.strftime("%Y%m%d_%H%M%S.") + "%06d" % time.utc.usec
        end
      end
    end
  end
end
