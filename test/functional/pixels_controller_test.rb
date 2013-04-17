require 'test_helper'

class PixelsControllerTest < ActionController::TestCase
  setup do
    @pixel = pixels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pixels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pixel" do
    assert_difference('Pixel.count') do
      post :create, pixel: { code: @pixel.code }
    end

    assert_redirected_to pixel_path(assigns(:pixel))
  end

  test "should show pixel" do
    get :show, id: @pixel
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pixel
    assert_response :success
  end

  test "should update pixel" do
    put :update, id: @pixel, pixel: { code: @pixel.code }
    assert_redirected_to pixel_path(assigns(:pixel))
  end

  test "should destroy pixel" do
    assert_difference('Pixel.count', -1) do
      delete :destroy, id: @pixel
    end

    assert_redirected_to pixels_path
  end
end
