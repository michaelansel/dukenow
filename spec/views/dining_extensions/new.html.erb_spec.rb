require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/dining_extensions/new.html.erb" do
  include DiningExtensionsHelper

  before(:each) do
    assigns[:dining_extension] = stub_model(DiningExtension,
      :new_record? => true
    )
  end

  it "renders new dining_extension form" do
    render

    response.should have_tag("form[action=?][method=post]", dining_extensions_path) do
    end
  end
end
