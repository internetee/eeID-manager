require 'test_helper'

class AdminServicesIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @service = services(:one)
    sign_in users(:administrator)
  end

end