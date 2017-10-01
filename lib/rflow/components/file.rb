require 'rflow/components/file/extensions'
require 'rflow/components/file/directory_watcher'
require 'rflow/components/file/output_raw_to_files'

# RFlow classes.
class RFlow
  # RFlow component classes.
  module Components
    # File RFlow component classes.
    module File
      # Load the schemas
      # @!visibility private
      SCHEMA_DIRECTORY = ::File.expand_path(::File.join(::File.dirname(__FILE__), '..', '..', '..', 'schema'))

      # @!visibility private
      SCHEMA_FILES = {
        'file.avsc' => 'RFlow::Message::Data::File',
      }

      SCHEMA_FILES.each do |file_name, data_type_name|
        schema_string = ::File.read(::File.join(SCHEMA_DIRECTORY, file_name))
        RFlow::Configuration.add_available_data_type data_type_name, 'avro', schema_string
      end

      # Load the data extensions
      RFlow::Configuration.add_available_data_extension('RFlow::Message::Data::File',
                                                        RFlow::Components::File::Extensions::FileExtension)
    end
  end
end
