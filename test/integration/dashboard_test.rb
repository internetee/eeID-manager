require 'test_helper'

class DashboardsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def test_redirect_to_admin_authentications
    sign_in users(:administrator)
    get dashboard_path
    assert_redirected_to admin_authentications_path
  end
end