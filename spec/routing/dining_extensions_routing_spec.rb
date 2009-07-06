require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DiningExtensionsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "dining_extensions", :action => "index").should == "/dining_extensions"
    end

    it "maps #new" do
      route_for(:controller => "dining_extensions", :action => "new").should == "/dining_extensions/new"
    end

    it "maps #show" do
      route_for(:controller => "dining_extensions", :action => "show", :id => "1").should == "/dining_extensions/1"
    end

    it "maps #edit" do
      route_for(:controller => "dining_extensions", :action => "edit", :id => "1").should == "/dining_extensions/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "dining_extensions", :action => "create").should == {:path => "/dining_extensions", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "dining_extensions", :action => "update", :id => "1").should == {:path =>"/dining_extensions/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "dining_extensions", :action => "destroy", :id => "1").should == {:path =>"/dining_extensions/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/dining_extensions").should == {:controller => "dining_extensions", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/dining_extensions/new").should == {:controller => "dining_extensions", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/dining_extensions").should == {:controller => "dining_extensions", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/dining_extensions/1").should == {:controller => "dining_extensions", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/dining_extensions/1/edit").should == {:controller => "dining_extensions", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/dining_extensions/1").should == {:controller => "dining_extensions", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/dining_extensions/1").should == {:controller => "dining_extensions", :action => "destroy", :id => "1"}
    end
  end
end
