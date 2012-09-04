require 'spec_helper.rb'

describe RFlow::Components::File::OutputRawToFiles do

  it "should correctly process file name prefix/suffix" do
    component = described_class.new(1)
    component.configure!('file_name_prefix' => 'boom', 'file_name_suffix' => 'town', 'directory_path' => '/tmp')
    component.send(:output_file_name).should match(/boom.*0001town/)
  end

  it "should do stuff" do
    component = described_class.new(1)
    component.configure!('file_name_prefix' => 'boom.', 'file_name_suffix' => '.town', 'directory_path' => '/tmp')

    message = RFlow::Message.new('RFlow::Message::Data::Raw')
    message.data.raw = 'boomertown'
    
    output_file_path = component.process_message nil, nil, nil, message

    File.exist?(output_file_path).should be_true
  end
  
end
