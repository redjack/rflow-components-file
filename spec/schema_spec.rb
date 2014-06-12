require 'spec_helper'

describe 'RFlow::Message::Data::File Avro Schema' do
  let(:schema) { RFlow::Configuration.available_data_types['RFlow::Message::Data::File']['avro'] }

  it "should encode and decode an object" do
    file = {
      'path' => '/full/file/path/filename',
      'size' => 1,
      'content' => 'CONTENT',
      'creation_timestamp' => 'CREATEDTIMESTRING',
      'modification_timestamp' => 'MODIFIEDTIMESTRING',
      'access_timestamp' => 'ACCESSEDTIMESTRING'
    }

    expect { encode_avro(schema, file) }.to_not raise_error
    encoded_file = encode_avro(schema, file)

    expect { decode_avro(schema, encoded_file) }.to_not raise_error
    decoded_file = decode_avro(schema, encoded_file)

    expect(decoded_file).to eq(file)
  end
end
