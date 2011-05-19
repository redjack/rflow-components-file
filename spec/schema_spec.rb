require 'spec_helper.rb'

describe 'RFlow::Message::Data::File Avro Schema' do
  before(:each) do
    @schema_string = RFlow::Configuration.available_data_types['RFlow::Message::Data::File']['avro']
  end
  
  it "should encode and decode an object" do
    file = {
      'path' => '/full/file/path/filename',
      'size' => 1,
      'content' => 'CONTENT',
      'creation_timestamp' => 'CREATEDTIMESTRING',
      'modification_timestamp' => 'MODIFIEDTIMESTRING',
      'access_timestamp' => 'ACCESSEDTIMESTRING'
    }

    expect {encode_avro(@schema_string, file)}.to_not raise_error
    avro_encoded_file = encode_avro(@schema_string, file)

    expect {decode_avro(@schema_string, avro_encoded_file)}.to_not raise_error
    decoded_file = decode_avro(@schema_string, avro_encoded_file)

    decoded_file.should == file

  end
end

