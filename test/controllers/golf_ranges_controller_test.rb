require "test_helper"

class GolfRangesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get golf_ranges_url
    assert_response :success
  end
end
