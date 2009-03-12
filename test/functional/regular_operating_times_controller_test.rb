require 'test_helper'

class RegularOperatingTimesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:regular_operating_times)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create regular_operating_time" do
    assert_difference('RegularOperatingTime.count') do
      post :create, :regular_operating_time => { }
    end

    assert_redirected_to regular_operating_time_path(assigns(:regular_operating_time))
  end

  test "should show regular_operating_time" do
    get :show, :id => regular_operating_times(:open).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => regular_operating_times(:open).id
    assert_response :success
  end

  test "should update regular_operating_time" do
    put :update, :id => regular_operating_times(:open).id, :regular_operating_time => { }
    assert_redirected_to regular_operating_time_path(assigns(:regular_operating_time))
  end

  test "should destroy regular_operating_time" do
    assert_difference('RegularOperatingTime.count', -1) do
      delete :destroy, :id => regular_operating_times(:open).id
    end

    assert_redirected_to regular_operating_times_path
  end
end
