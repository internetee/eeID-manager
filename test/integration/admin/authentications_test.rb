require 'test_helper'

class AuthenticationIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:administrator)
    sign_in @user
  end
end