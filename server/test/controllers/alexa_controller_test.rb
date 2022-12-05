require "test_helper"

class AlexaControllerTest < ActionDispatch::IntegrationTest
  test "should get getLastTemperature" do
    get alexa_getLastTemperature_url
    assert_response :success
  end

  test "should get getMinTemperatureToday" do
    get alexa_getMinTemperatureToday_url
    assert_response :success
  end

  test "should get getMaxTemperatureToday" do
    get alexa_getMaxTemperatureToday_url
    assert_response :success
  end
end
