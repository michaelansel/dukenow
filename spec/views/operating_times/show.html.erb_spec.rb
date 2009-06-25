require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/operating_times/show.html.erb" do
  include OperatingTimesHelper
  before(:each) do
    assigns[:operating_time] = @operating_time = stub_model(OperatingTime)
    assigns[:place] = @place = stub_model(Place)
    @operating_time.place = @place
  end

  it "renders attributes in <p>" do
    pending('Fix libRelativeTime')
    render
  end
end

