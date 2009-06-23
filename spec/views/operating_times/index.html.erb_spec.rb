require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/operating_times/index.html.erb" do
  include OperatingTimesHelper
  
  before(:each) do
    assigns[:operating_times] = [
      stub_model(OperatingTime),
      stub_model(OperatingTime)
    ]
  end

  it "renders a list of operating_times" do
    render
  end
end

