require 'eventmachine'
require 'rflow/component'
require 'digest/md5'
require 'rflow/components/file/output_to_disk'

class RFlow
  module Components
    module File
      # Component that receives +RFlow::Message+s of type +RFlow::Message::Data::Raw+
      # and writes new files to disk whose contents are the raw bytes of the message.
      class OutputRawToFiles < RFlow::Component
        include RFlow::Components::File::OutputToDisk

        # Input port where +RFlow::Message+s of type +RFlow::Message::Data::Raw+ are
        # received. When one is, a new file is written based on the message's properties.
        # @return [RFlow::Component::InputPort]
        input_port :raw_port

        # RFlow-called method when a message is received.
        # @return [void]
        def process_message(input_port, input_port_key, connection, message)
          return unless message.data_type_name == 'RFlow::Message::Data::Raw'
          write_to_file(message.properties) {|file| file.write(message.data.raw) }
        end
      end
    end
  end
end
