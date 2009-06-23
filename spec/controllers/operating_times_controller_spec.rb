require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OperatingTimesController do

  def mock_operating_time(stubs={})
    @mock_operating_time ||= mock_model(OperatingTime, stubs)
  end
  
  describe "GET index" do
    it "assigns all operating_times as @operating_times" do
      OperatingTime.stub!(:find).with(:all).and_return([mock_operating_time])
      get :index
      assigns[:operating_times].should == [mock_operating_time]
    end
  end

  describe "GET show" do
    it "assigns the requested operating_time as @operating_time" do
      OperatingTime.stub!(:find).with("37").and_return(mock_operating_time)
      get :show, :id => "37"
      assigns[:operating_time].should equal(mock_operating_time)
    end
  end

  describe "GET new" do
    it "assigns a new operating_time as @operating_time" do
      OperatingTime.stub!(:new).and_return(mock_operating_time)
      get :new
      assigns[:operating_time].should equal(mock_operating_time)
    end
  end

  describe "GET edit" do
    it "assigns the requested operating_time as @operating_time" do
      OperatingTime.stub!(:find).with("37").and_return(mock_operating_time)
      get :edit, :id => "37"
      assigns[:operating_time].should equal(mock_operating_time)
    end
  end

  describe "POST create" do
    
    describe "with valid params" do
      it "assigns a newly created operating_time as @operating_time" do
        OperatingTime.stub!(:new).with({'these' => 'params'}).and_return(mock_operating_time(:save => true))
        post :create, :operating_time => {:these => 'params'}
        assigns[:operating_time].should equal(mock_operating_time)
      end

      it "redirects to the created operating_time" do
        OperatingTime.stub!(:new).and_return(mock_operating_time(:save => true))
        post :create, :operating_time => {}
        response.should redirect_to(operating_time_url(mock_operating_time))
      end
    end
    
    describe "with invalid params" do
      it "assigns a newly created but unsaved operating_time as @operating_time" do
        OperatingTime.stub!(:new).with({'these' => 'params'}).and_return(mock_operating_time(:save => false))
        post :create, :operating_time => {:these => 'params'}
        assigns[:operating_time].should equal(mock_operating_time)
      end

      it "re-renders the 'new' template" do
        OperatingTime.stub!(:new).and_return(mock_operating_time(:save => false))
        post :create, :operating_time => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested operating_time" do
        OperatingTime.should_receive(:find).with("37").and_return(mock_operating_time)
        mock_operating_time.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :operating_time => {:these => 'params'}
      end

      it "assigns the requested operating_time as @operating_time" do
        OperatingTime.stub!(:find).and_return(mock_operating_time(:update_attributes => true))
        put :update, :id => "1"
        assigns[:operating_time].should equal(mock_operating_time)
      end

      it "redirects to the operating_time" do
        OperatingTime.stub!(:find).and_return(mock_operating_time(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(operating_time_url(mock_operating_time))
      end
    end
    
    describe "with invalid params" do
      it "updates the requested operating_time" do
        OperatingTime.should_receive(:find).with("37").and_return(mock_operating_time)
        mock_operating_time.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :operating_time => {:these => 'params'}
      end

      it "assigns the operating_time as @operating_time" do
        OperatingTime.stub!(:find).and_return(mock_operating_time(:update_attributes => false))
        put :update, :id => "1"
        assigns[:operating_time].should equal(mock_operating_time)
      end

      it "re-renders the 'edit' template" do
        OperatingTime.stub!(:find).and_return(mock_operating_time(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested operating_time" do
      OperatingTime.should_receive(:find).with("37").and_return(mock_operating_time)
      mock_operating_time.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the operating_times list" do
      OperatingTime.stub!(:find).and_return(mock_operating_time(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(operating_times_url)
    end
  end

end
