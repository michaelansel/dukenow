require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DiningExtensionsController do

  def mock_dining_extension(stubs={})
    @mock_dining_extension ||= mock_model(DiningExtension, stubs)
  end

  describe "GET index" do
    it "assigns all dining_extensions as @dining_extensions" do
      DiningExtension.stub!(:find).with(:all).and_return([mock_dining_extension])
      get :index
      assigns[:dining_extensions].should == [mock_dining_extension]
    end
  end

  describe "GET show" do
    it "assigns the requested dining_extension as @dining_extension" do
      DiningExtension.stub!(:find).with("37").and_return(mock_dining_extension)
      get :show, :id => "37"
      assigns[:dining_extension].should equal(mock_dining_extension)
    end
  end

  describe "GET new" do
    it "assigns a new dining_extension as @dining_extension" do
      DiningExtension.stub!(:new).and_return(mock_dining_extension)
      get :new
      assigns[:dining_extension].should equal(mock_dining_extension)
    end
  end

  describe "GET edit" do
    it "assigns the requested dining_extension as @dining_extension" do
      DiningExtension.stub!(:find).with("37").and_return(mock_dining_extension)
      get :edit, :id => "37"
      assigns[:dining_extension].should equal(mock_dining_extension)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created dining_extension as @dining_extension" do
        DiningExtension.stub!(:new).with({'these' => 'params'}).and_return(mock_dining_extension(:save => true))
        post :create, :dining_extension => {:these => 'params'}
        assigns[:dining_extension].should equal(mock_dining_extension)
      end

      it "redirects to the created dining_extension" do
        DiningExtension.stub!(:new).and_return(mock_dining_extension(:save => true))
        post :create, :dining_extension => {}
        response.should redirect_to(dining_extension_url(mock_dining_extension))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved dining_extension as @dining_extension" do
        DiningExtension.stub!(:new).with({'these' => 'params'}).and_return(mock_dining_extension(:save => false))
        post :create, :dining_extension => {:these => 'params'}
        assigns[:dining_extension].should equal(mock_dining_extension)
      end

      it "re-renders the 'new' template" do
        DiningExtension.stub!(:new).and_return(mock_dining_extension(:save => false))
        post :create, :dining_extension => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested dining_extension" do
        DiningExtension.should_receive(:find).with("37").and_return(mock_dining_extension)
        mock_dining_extension.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :dining_extension => {:these => 'params'}
      end

      it "assigns the requested dining_extension as @dining_extension" do
        DiningExtension.stub!(:find).and_return(mock_dining_extension(:update_attributes => true))
        put :update, :id => "1"
        assigns[:dining_extension].should equal(mock_dining_extension)
      end

      it "redirects to the dining_extension" do
        DiningExtension.stub!(:find).and_return(mock_dining_extension(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(dining_extension_url(mock_dining_extension))
      end
    end

    describe "with invalid params" do
      it "updates the requested dining_extension" do
        DiningExtension.should_receive(:find).with("37").and_return(mock_dining_extension)
        mock_dining_extension.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :dining_extension => {:these => 'params'}
      end

      it "assigns the dining_extension as @dining_extension" do
        DiningExtension.stub!(:find).and_return(mock_dining_extension(:update_attributes => false))
        put :update, :id => "1"
        assigns[:dining_extension].should equal(mock_dining_extension)
      end

      it "re-renders the 'edit' template" do
        DiningExtension.stub!(:find).and_return(mock_dining_extension(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested dining_extension" do
      DiningExtension.should_receive(:find).with("37").and_return(mock_dining_extension)
      mock_dining_extension.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the dining_extensions list" do
      DiningExtension.stub!(:find).and_return(mock_dining_extension(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(dining_extensions_url)
    end
  end

end
