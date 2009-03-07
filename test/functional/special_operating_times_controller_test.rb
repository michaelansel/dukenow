require 'test_helper'

class SpecialOperatingTimesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:special_operating_times)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create special_operating_time" do
    assert_difference('SpecialOperatingTime.count') do
      post :create, :special_operating_time => { }
    end

    assert_redirected_to special_operating_time_path(assigns(:special_operating_time))
  end

  test "should show special_operating_time" do
    get :show, :id => special_operating_times(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => special_operating_times(:one).id
    assert_response :success
  end

  test "should update special_operating_time" do
    put :update, :id => special_operating_times(:one).id, :special_operating_time => { }
    assert_redirected_to special_operating_time_path(assigns(:special_operating_time))
  end

  test "should destroy special_operating_time" do
    assert_difference('SpecialOperatingTime.count', -1) do
      delete :destroy, :id => special_operating_times(:one).id
    end

    assert_redirected_to special_operating_times_path
  end
end
