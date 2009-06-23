require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OperatingTimesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "operating_times", :action => "index").should == "/operating_times"
    end
  
    it "maps #new" do
      route_for(:controller => "operating_times", :action => "new").should == "/operating_times/new"
    end
  
    it "maps #show" do
      route_for(:controller => "operating_times", :action => "show", :id => "1").should == "/operating_times/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "operating_times", :action => "edit", :id => "1").should == "/operating_times/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "operating_times", :action => "create").should == {:path => "/operating_times", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "operating_times", :action => "update", :id => "1").should == {:path =>"/operating_times/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "operating_times", :action => "destroy", :id => "1").should == {:path =>"/operating_times/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/operating_times").should == {:controller => "operating_times", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/operating_times/new").should == {:controller => "operating_times", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/operating_times").should == {:controller => "operating_times", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/operating_times/1").should == {:controller => "operating_times", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/operating_times/1/edit").should == {:controller => "operating_times", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/operating_times/1").should == {:controller => "operating_times", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/operating_times/1").should == {:controller => "operating_times", :action => "destroy", :id => "1"}
    end
  end
end
