require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/dining_extensions/index.html.erb" do
  include DiningExtensionsHelper

  before(:each) do
    assigns[:dining_extensions] = [
      stub_model(DiningExtension),
      stub_model(DiningExtension)
    ]
  end

  it "renders a list of dining_extensions" do
    render
  end
end
