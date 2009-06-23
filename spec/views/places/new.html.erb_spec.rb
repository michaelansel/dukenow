require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/places/new.html.erb" do
  include PlacesHelper
  
  before(:each) do
    assigns[:place] = stub_model(Place,
      :new_record? => true
    )
  end

  it "renders new place form" do
    render
    
    response.should have_tag("form[action=?][method=post]", places_path) do
    end
  end
end


