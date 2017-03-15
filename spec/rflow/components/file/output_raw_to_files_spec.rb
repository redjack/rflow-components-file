require 'spec_helper'

class RFlow
  module Components
    module File
      describe OutputRawToFiles do
        let(:config) do
          {'file_name_prefix' => 'boom',
           'file_name_suffix' => '.town',
           'directory_path'   => '/tmp'}
        end

        let(:component) { described_class.new.tap {|c| c.configure!(config) } }

        it 'should correctly process file name prefix/suffix when given message properties with no uuid' do
          expect(component.send(:output_file_name, {})).to match(/boom\..+\.[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.town/)
        end

        it 'should correctly process file name prefix/suffix when given message properties with uuid' do
          props = { 'data_uuid' => 'uuid' }
          expect(component.send(:output_file_name, props)).to match(/boom\..+\.uuid\.town/)
        end

        it "should do stuff" do
          message = Message.new('RFlow::Message::Data::Raw').tap do |m|
            m.data.raw = 'boomertown'
          end

          output_file_path = component.process_message nil, nil, nil, message

          expect(::File.exist?(output_file_path)).to be true
        end
      end
    end
  end
end
