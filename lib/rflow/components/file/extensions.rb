class RFlow
  # @!parse
  #   # Fake classes in this tree to document the actual message types.
  #   class Message
  #     # Fake classes in this tree to document the actual message types.
  #     class Data
  #       # A message representing a file on disk, including its contents. The file might no longer exist.
  #       class File
  #         # @!attribute path
  #         #   The file's pathname.
  #         #   @return [String]
  #
  #         # @!attribute size
  #         #   The file's size.
  #         #   @return [Integer]
  #
  #         # @!attribute content
  #         #   The file's binary content.
  #         #   @return [String]
  #
  #         # @!attribute creation_timestamp
  #         #   The file's creation timestamp as an XML schema-compatible dateTime string.
  #         #   @return [String]
  #
  #         # @!attribute modification_timestamp
  #         #   The file's modification timestamp as an XML schema-compatible dateTime string.
  #         #   @return [String]
  #
  #         # @!attribute access_timestamp
  #         #   The file's access timestamp as an XML schema-compatible dateTime string.
  #         #   @return [String]
  #
  #         # Just here to force Yard to create documentation.
  #         # @!visibility private
  #         def initialize; end
  #       end
  #     end
  #   end

  # RFlow component classes.
  module Components
    module File
      # @!visibility private
      module Extensions
        # Need to be careful when extending to not clobber data already in data_object
        # @!visibility private
        module FileExtension
          # @!visibility private
          def self.extended(base_data)
            base_data.data_object ||= {
              'path' => '/', 'size' => 0, 'content' => '',
              'creation_timestamp' => nil, 'modification_timestamp' => nil, 'access_timestamp' => nil
            }
          end

          # Default/string accessors
          ['path', 'content'].each do |name|
            define_method name do |*args|
              data_object[name]
            end
            define_method :"#{name}=" do |*args|
              data_object[name] = args.first
            end
          end

          # Integer Accessors
          ['size'].each do |name|
            define_method name do |*args|
              data_object[name]
            end
            define_method :"#{name}=" do |*args|
              data_object[name] = args.first.to_i
            end
          end

          # Timestamp Accessors.  Note, the precision of the
          # XMLTimestamp is set to 9 digits, meaning that the time you
          # put in might be slightly different from the time you read
          # out.
          ['creation_timestamp', 'modification_timestamp', 'access_timestamp'].each do |name|
            define_method name do |*args|
              data_object[name] ? Time.xmlschema(data_object[name]) : nil
            end
            define_method :"#{name}=" do |*args|
              if args.first.is_a? Time
                data_object[name] = args.first.xmlschema(9)
              else
                data_object[name] = args.first
              end
            end
          end
        end
      end
    end
  end
end
