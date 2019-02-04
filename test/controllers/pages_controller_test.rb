require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get results" do
    get pages_results_url
    assert_response :success
  end

end
