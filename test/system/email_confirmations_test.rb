require 'application_system_test_case'

class EmailConfirmationTest < ApplicationSystemTestCase
  def test_dashboard_page
    user = users(:customer)
    user.email = 'new@address.com'
    user.save
    visit user_confirmation_url(confirmation_token: user.confirmation_token)

    assert_text 'Your email address has been successfully confirmed.'
  end
end