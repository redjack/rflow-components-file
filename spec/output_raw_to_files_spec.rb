require 'spec_helper.rb'

describe RFlow::Components::File::OutputRawToFiles do

  before(:each) do
  end

  let :component_config do
    OpenStruct.new(:name         => 'port name',
                   :uuid         => 0,
                   :input_ports  => [],
                   :output_ports => [],
                   :options      => {
                     'file_name_prefix' => 'boom',
                     'file_name_suffix' => '.town',
                     'directory_path'   => '/tmp'})
  end

  let :component do
    described_class.new(component_config)
  end

  it "should correctly process file name prefix/suffix" do
    component.send(:output_file_name).should match(/boom.*0001.town/)
  end

  it "should do stuff" do
    message = RFlow::Message.new('RFlow::Message::Data::Raw')
    message.data.raw = 'boomertown'

    output_file_path = component.process_message nil, nil, nil, message

    File.exist?(output_file_path).should be_true
  end

end
