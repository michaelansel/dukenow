require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/operating_times/index.html.erb" do
  include OperatingTimesHelper
  
  before(:each) do
    @operating_times = [
      stub_model(OperatingTime),
      stub_model(OperatingTime)
    ]
    @operating_times[0].place = stub_model(Place)
    @operating_times[1].place = stub_model(Place)
    assigns[:operating_times] = @operating_times
  end

  it "renders a list of operating_times" do
    pending('Fix libRelativeTime')
    render
  end
end

