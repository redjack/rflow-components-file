require 'spec_helper.rb'

require 'time'

describe RFlow::Components::File::Extensions::FileExtension do
  before(:each) do
    @schema_string = RFlow::Configuration.available_data_types['RFlow::Message::Data::File']['avro']
  end

  it "should add the extension to RFlow::Configuration" do
    RFlow::Configuration.available_data_extensions['RFlow::Message::Data::File'].should include(described_class)
  end
  
  it "should set the defaults" do
    file = RFlow::Message.new('RFlow::Message::Data::File')

    file.data.path.should == '/'
    file.data.size.should == 0
    file.data.content.should == ''
    file.data.creation_timestamp.should == nil
    file.data.modification_timestamp.should == nil
    file.data.accessed_timestamp.should == nil
  end

  it "should correctly use integers or strings for size field" do
    file = RFlow::Message.new('RFlow::Message::Data::File')

    file.data.size.should == 0
    file.data.size = 10
    file.data.size.should == 10
    file.data.size = '20'
    file.data.size == 20
  end

  it "should correctly use Time or xmlschema strings for timestamp fields" do
    file = RFlow::Message.new('RFlow::Message::Data::File')

    file.data.creation_timestamp.should == nil
    now = Time.now

    file.data.creation_timestamp = now
    file.data.creation_timestamp.should == Time.xmlschema(now.xmlschema(9))

    file.data.creation_timestamp = now.xmlschema
    file.data.creation_timestamp.should == Time.xmlschema(now.xmlschema)
  end

  
end
