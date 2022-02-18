require 'application_system_test_case'

class AuthenticationsTest < ApplicationSystemTestCase
  def setup
    @user = users(:customer)
    sign_in @user
  end

  def test_visit_authentication_page
    visit authentications_path

    assert_text 'Authentications'
    assert page.has_css?('.ui.table.unstackable.fixed')
  end
end