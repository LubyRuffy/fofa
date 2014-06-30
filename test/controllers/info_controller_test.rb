require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  test "should get gov" do
    get :gov
    assert_response :success
  end

end
