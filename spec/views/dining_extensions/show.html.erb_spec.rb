require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/dining_extensions/show.html.erb" do
  include DiningExtensionsHelper
  before(:each) do
    assigns[:dining_extension] = @dining_extension = stub_model(DiningExtension)
  end

  it "renders attributes in <p>" do
    render
  end
end
