require 'application_system_test_case'

class UsersAdminTest < ApplicationSystemTestCase
  def setup
    super
    @user_admin = users(:administrator)
    @user_participant = users(:customer)
    sign_in @user_admin
  end

  def test_visit_users_page
    visit_users_page
  end

  def test_search_users
    visit_users_page
    fill_in 'Search', with: 'Joe John'

    find(:css, '.ui.icon.primary.button').click

    assert_text 'User search'
    assert_text 'Joe John'
  end

  def test_edit_user_info
    visit edit_admin_user_path(@user_participant)
    fill_in 'user_surname', with: 'Johnson'

    click_on 'Update'

    assert_text 'Personal information'
    assert_text 'Johnson'
  end

  def test_edit_user_info_with_invalid_attributes
    visit edit_admin_user_path(@user_participant)
    fill_in 'user_surname', with: '<html>'

    click_on 'Update'

    assert_text 'Please, note, what the only characters allowed is utf-characters'
    assert_current_path "/admin/users/#{@user_participant.id}"
  end

  def test_destroy_user
    visit admin_user_path(@user_participant)

    click_on 'Delete'

    accept_alert
    assert_text 'Deleted successfully.'
    assert_no_text @user_participant.given_names
  end

  private

  def visit_users_page
    visit admin_users_path({ order: { 'users.surname': 'asc' } })

    assert_text 'Users'
    assert page.has_css?('.ui.table.unstackable.fixed')
  end

  def visit_specific_user_page
    visit_users_page

    click_link @user_participant.given_names

    assert_text @user_participant.given_names
    assert_text 'User'
    assert_text 'Personal information'
    assert_text 'Billing information'
  end
end
