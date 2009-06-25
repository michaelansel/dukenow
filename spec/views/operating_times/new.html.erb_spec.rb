require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/operating_times/new.html.erb" do
  include OperatingTimesHelper
  
  before(:each) do
    assigns[:operating_time] = stub_model(OperatingTime,
      :new_record? => true
    )
    assigns[:places] = @places = [stub_model(Place),stub_model(Place)]
  end

  it "renders new operating_time form" do
    pending('Fix libRelativeTime')
    render
    
    response.should have_tag("form[action=?][method=post]", operating_times_path) do
    end
  end
end


