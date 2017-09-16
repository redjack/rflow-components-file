require 'uuidtools'

class RFlow
  module Components
    module File
      # To be included into any component that plans to output files to disk.
      # Provides default configuration and a {write_to_file} method.
      #
      # Best not to depend on the filename other than the prefix and suffix
      # portions as it is implementation-dependent.
      #
      # Mixed-in component will support the following config parameters:
      # - +directory_path+ - directory to write files into
      # - +file_name_prefix+ - written files will always begin with this prefix
      # - +file_name_suffix+ - written files will always end with this suffix
      module OutputToDisk
        # Default config.
        DEFAULT_CONFIG = {
          'directory_path'  => '/tmp',
          'file_name_prefix' => 'output.',
          'file_name_suffix' => '.out',
        }

        # @!visibility private
        attr_accessor :config, :directory_path, :file_name_prefix, :file_name_suffix

        # RFlow-called method at startup.
        # @return [void]
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

        # Write out a file to disk based on message properties. Filename is implementation-dependent
        # but will certainly contain the data UUID, priority, filename prefix, suffix, and a timestamp
        # (properties +data_uuid+, +priority+ plus config variables).
        #
        # Opens the file and +yield+s it back to the caller for actual writing. Caller should return
        # the number of bytes written.
        #
        # @return [String] the final output file path
        def write_to_file(properties)
          properties ||= {}
          begin
            final_output_file_name = output_file_name(properties)

            temp_output_file_path = ::File.join(directory_path, ".#{final_output_file_name}")
            final_output_file_path = ::File.join(directory_path, "#{final_output_file_name}")

            RFlow.logger.debug { "#{self.class}: Outputting message to #{final_output_file_path} (via #{temp_output_file_path})" }

            ::File.open(temp_output_file_path, ::File::CREAT|::File::EXCL|::File::RDWR, 0644, :external_encoding => 'BINARY') do |file|
              file.flock(::File::LOCK_EX)
              bytes_written = yield file

              file.flush
              raise IOError, "file size of '#{::File.size(temp_output_file_path)}' does not match expected size of '#{bytes_written}'" unless ::File.size(temp_output_file_path) == bytes_written
            end
            ::File.rename(temp_output_file_path, final_output_file_path)
            final_output_file_path
          rescue StandardError, Errno::EEXIST => e
            RFlow.logger.error { "#{self.class} encountered #{e.message} when creating #{temp_output_file_path}" }
            begin
              ::File.delete(temp_output_file_path)
            rescue => f
              RFlow.logger.debug {"#{self.class} encountered #{f.message} on cleanup of #{temp_output_file_path}" }
            end
            raise e
          end
        end

        private
        def output_file_name(properties)
          uuid = properties['data_uuid'] || UUIDTools::UUID.random_create.to_s
          priority = properties['priority'] || 0
          "#{file_name_prefix}.#{'%03d' % priority}.#{current_timestamp}.#{uuid}#{file_name_suffix}"
        end

        def current_timestamp
          time = Time.now
          time.utc.strftime("%Y%m%d_%H%M%S.") + "%06d" % time.utc.usec
        end
      end
    end
  end
end
