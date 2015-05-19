require 'test_helper'

class WeatherControllerTest < ActionController::TestCase
  test "should get locations" do
    get :locations
    assert_response :success
  end

end
