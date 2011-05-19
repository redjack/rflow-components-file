class RFlow
  module Components
    module File
      
      # The set of extensions to add capability to HTTP data types
      module Extensions
        
        # Need to be careful when extending to not clobber data already in data_object
        module FileExtension
          def self.extended(base_data)
            base_data.data_object ||= {
              'path' => '/', 'size' => 0, 'content' => '',
              'creation_timestamp' => nil, 'modification_timestamp' => nil, 'accessed_timestamp' => nil
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
          ['creation_timestamp', 'modification_timestamp', 'accessed_timestamp'].each do |name|
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
