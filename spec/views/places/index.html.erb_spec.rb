require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/places/index.html.erb" do
  include PlacesHelper
  
  before(:each) do
    assigns[:places] = [
      stub_model(Place),
      stub_model(Place)
    ]
  end

  it "renders a list of places" do
    render
  end
end

