require 'test_helper'

class OperatingTimesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:operating_times)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create operating_time" do
    assert_difference('OperatingTime.count') do
      post :create, :operating_time => { }
    end

    assert_redirected_to operating_time_path(assigns(:operating_time))
  end

  test "should show operating_time" do
    get :show, :id => operating_times(:openNow).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => operating_times(:openNow).id
    assert_response :success
  end

  test "should update operating_time" do
    put :update, :id => operating_times(:openNow).id, :operating_time => { }
    assert_redirected_to operating_time_path(assigns(:operating_time))
  end

  test "should destroy operating_time" do
    assert_difference('OperatingTime.count', -1) do
      delete :destroy, :id => operating_times(:openNow).id
    end

    assert_redirected_to operating_times_path
  end
end
