require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/places/show.html.erb" do
  include PlacesHelper
  before(:each) do
    assigns[:place] = @place = stub_model(Place)
  end

  it "renders attributes in <p>" do
    render
  end
end

