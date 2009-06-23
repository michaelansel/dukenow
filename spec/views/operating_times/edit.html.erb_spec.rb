require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/operating_times/edit.html.erb" do
  include OperatingTimesHelper
  
  before(:each) do
    assigns[:operating_time] = @operating_time = stub_model(OperatingTime,
      :new_record? => false
    )
  end

  it "renders the edit operating_time form" do
    render
    
    response.should have_tag("form[action=#{operating_time_path(@operating_time)}][method=post]") do
    end
  end
end


