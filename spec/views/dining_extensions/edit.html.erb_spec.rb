require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/dining_extensions/edit.html.erb" do
  include DiningExtensionsHelper

  before(:each) do
    assigns[:dining_extension] = @dining_extension = stub_model(DiningExtension,
      :new_record? => false
    )
  end

  it "renders the edit dining_extension form" do
    render

    response.should have_tag("form[action=#{dining_extension_path(@dining_extension)}][method=post]") do
    end
  end
end
