require 'eventmachine'
require 'rflow/component'
require 'digest/md5'
require 'rflow/components/file/output_to_disk'

class RFlow
  module Components
    module File
      class OutputRawToFiles < RFlow::Component
        include RFlow::Components::File::OutputToDisk
        input_port :raw_port

        def process_message(input_port, input_port_key, connection, message)
          return unless message.data_type_name == 'RFlow::Message::Data::Raw'
          write_to_file(message.properties) {|file| file.write(message.data.raw) }
        end
      end
    end
  end
end
