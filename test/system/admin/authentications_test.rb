require 'application_system_test_case'


class AuthenticationsAdminTest < ApplicationSystemTestCase
  def setup
    super
    @user = users(:administrator)
    sign_in @user
  end

  def test_visit_authentication_page
    visit admin_authentications_path

    assert_text 'Authentications'
    assert_text 'Joe John Participant'
    assert_text 'TARA USER'
    assert page.has_css?('.ui.table.unstackable.fixed')
  end
end