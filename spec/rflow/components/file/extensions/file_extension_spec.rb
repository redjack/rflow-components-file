require 'spec_helper'
require 'time'

class RFlow
  module Components
    module File
      module Extensions
        describe FileExtension do
          it "should add the extension to RFlow::Configuration" do
            expect(Configuration.available_data_extensions['RFlow::Message::Data::File']).to include(described_class)
          end

          it "should set the defaults" do
            file = Message.new('RFlow::Message::Data::File').data.tap do |d|
              expect(d.path).to eq('/')
              expect(d.size).to eq(0)
              expect(d.content).to eq('')
              expect(d.creation_timestamp).to be_nil
              expect(d.modification_timestamp).to be_nil
              expect(d.access_timestamp).to be_nil
            end
          end

          it "should correctly use integers or strings for size field" do
            Message.new('RFlow::Message::Data::File').data.tap do |d|
              expect(d.size).to eq(0)
              d.size = 10
              expect(d.size).to eq(10)
              d.size = '20'
              d.size == 20
            end
          end

          it "should correctly use Time or xmlschema strings for timestamp fields" do
            Message.new('RFlow::Message::Data::File').data.tap do |d|
              now = Time.now
              expect(d.creation_timestamp).to be_nil
              d.creation_timestamp = now
              expect(d.creation_timestamp).to eq(Time.xmlschema(now.xmlschema(9)))
              d.creation_timestamp = now.xmlschema
              expect(d.creation_timestamp).to eq(Time.xmlschema(now.xmlschema))
            end
          end
        end
      end
    end
  end
end
