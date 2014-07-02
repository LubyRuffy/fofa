require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get addhost" do
    get :addhost
    assert_response :success
  end

end
