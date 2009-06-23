require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlacesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "places", :action => "index").should == "/places"
    end
  
    it "maps #new" do
      route_for(:controller => "places", :action => "new").should == "/places/new"
    end
  
    it "maps #show" do
      route_for(:controller => "places", :action => "show", :id => "1").should == "/places/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "places", :action => "edit", :id => "1").should == "/places/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "places", :action => "create").should == {:path => "/places", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "places", :action => "update", :id => "1").should == {:path =>"/places/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "places", :action => "destroy", :id => "1").should == {:path =>"/places/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/places").should == {:controller => "places", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/places/new").should == {:controller => "places", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/places").should == {:controller => "places", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/places/1").should == {:controller => "places", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/places/1/edit").should == {:controller => "places", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/places/1").should == {:controller => "places", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/places/1").should == {:controller => "places", :action => "destroy", :id => "1"}
    end
  end
end
