require 'spec_helper'

class RFlow
  module Components
    module File
      describe OutputRawToFiles do
        let(:component_config) do
          OpenStruct.new(:name         => 'port name',
                         :uuid         => 0,
                         :input_ports  => [],
                         :output_ports => [],
                         :options      => {
                           'file_name_prefix' => 'boom',
                           'file_name_suffix' => '.town',
                           'directory_path'   => '/tmp'})
        end

        let(:component) { described_class.new(component_config).tap {|c| c.configure!(component_config.options) } }

        it "should correctly process file name prefix/suffix" do
          component.send(:output_file_name).should match(/boom.*0001.town/)
        end

        it "should do stuff" do
          message = Message.new('RFlow::Message::Data::Raw').tap do |m|
            m.data.raw = 'boomertown'
          end

          output_file_path = component.process_message nil, nil, nil, message

          ::File.exist?(output_file_path).should be true
        end
      end
    end
  end
end
