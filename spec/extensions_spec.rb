require 'spec_helper'
require 'time'

describe RFlow::Components::File::Extensions::FileExtension do
  it "should add the extension to RFlow::Configuration" do
    RFlow::Configuration.available_data_extensions['RFlow::Message::Data::File'].should include(described_class)
  end

  it "should set the defaults" do
    file = RFlow::Message.new('RFlow::Message::Data::File').data.tap do |d|
      d.path.should == '/'
      d.size.should == 0
      d.content.should == ''
      d.creation_timestamp.should be_nil
      d.modification_timestamp.should be_nil
      d.access_timestamp.should be_nil
    end
  end

  it "should correctly use integers or strings for size field" do
    RFlow::Message.new('RFlow::Message::Data::File').data.tap do |d|
      d.size.should == 0
      d.size = 10
      d.size.should == 10
      d.size = '20'
      d.size == 20
    end
  end

  it "should correctly use Time or xmlschema strings for timestamp fields" do
    RFlow::Message.new('RFlow::Message::Data::File').data.tap do |d|
      now = Time.now
      d.creation_timestamp.should == nil
      d.creation_timestamp = now
      d.creation_timestamp.should == Time.xmlschema(now.xmlschema(9))
      d.creation_timestamp = now.xmlschema
      d.creation_timestamp.should == Time.xmlschema(now.xmlschema)
    end
  end
end
