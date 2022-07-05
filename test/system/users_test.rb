require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  def setup
    super
    @user_participant = users(:customer)
    @user_admin = users(:administrator)
  end

  def test_create_valid_user
    visit new_user_path

    fill_in 'Given names', with: 'John'
    fill_in 'Surname', with: 'Joe'
    fill_in 'Email', with: 'tere@test.ee'
    fill_in 'Mobile phone', with: '+37256677889'
    fill_in 'Billed to', with: 'John Joe'
    fill_in 'VAT code', with: '112233445566'
    fill_in 'Street', with: 'Bakery street'
    fill_in 'City', with: 'Tartu'
    fill_in 'Postal code', with: '13001'
    check_checkbox('user[accepts_terms_and_conditions]')

    fill_in 'Password', with: '12345AbcD'
    fill_in 'Password confirmation', with: '12345AbcD'

    assert_difference -> { User.count } do
      click_link_or_button 'Sign up'
    end

    assert_text 'You have to confirm your email address before continuing.'

    last_email = ActionMailer::Base.deliveries.last
    assert_equal('Confirmation instructions', last_email.subject)
    assert_equal(['tere@test.ee'], last_email.to)

    assert has_current_path? new_user_session_path
  end

  def test_create_user_with_invalid_attributes
    visit new_user_path

    fill_in 'Given names', with: '<>'
    fill_in 'Surname', with: '!!!'
    fill_in 'Mobile phone', with: '+37256677889'
    fill_in 'Billed to', with: 'John Joe'
    fill_in 'VAT code', with: '112233445566'
    fill_in 'Street', with: 'Bakery street'
    fill_in 'City', with: 'Tartu'
    fill_in 'Postal code', with: '13001'
    check_checkbox('user[accepts_terms_and_conditions]')

    fill_in 'Password', with: '12345AbcD'
    fill_in 'Password confirmation', with: '12345AbcD'

    assert_no_difference -> { User.count } do
      click_link_or_button 'Sign up'
    end

    assert_text 'Errors'
    assert_current_path '/users'
  end

  def test_sign_in_by_participant_user
    sign_in_by_user(@user_participant)

    assert_text('Signed in successfully')
    assert_text('Dashboard')
  end

  def test_sign_in_by_invalid_participant_user
    @user_participant.surname = '<html>'
    @user_participant.save(validate: false)
    sign_in_by_user(@user_participant)

    assert_text('Signed in successfully')
    assert_text('Dashboard')
    assert page.has_css?('.ui.message.ban')
  end

  def test_sign_in_by_administrator_user
    sign_in_by_user(@user_admin)

    assert_text('Signed in successfully')
    assert_text('Authentications')
  end

  def test_edit_user
    sign_in @user_participant
    visit edit_user_path(uuid: @user_participant.uuid)

    fill_in 'Surname', with: 'Tramp'
    fill_in 'Current password', with: 'password123'

    click_link_or_button 'Update'

    assert_text 'Updated successfully.'
    assert_text 'Tramp'
  end

  def test_edit_user_with_invalid_password
    sign_in @user_participant
    visit edit_user_path(uuid: @user_participant.uuid)

    fill_in 'Surname', with: 'Tramp'
    fill_in 'Current password', with: 'wrong'

    click_link_or_button 'Update'

    assert_text 'Incorrect current password'
  end

  def test_edit_user_with_invalid_attributes
    sign_in @user_participant
    visit edit_user_path(uuid: @user_participant.uuid)

    fill_in 'Given names', with: '<html>'
    fill_in 'Current password', with: 'password123'

    click_link_or_button 'Update'

    assert_text 'Please, note, what the only characters allowed is utf-characters'
  end

  def test_destroy_user_with_paid_invoices
    sign_in @user_participant
    visit me_path

    @user_participant.invoices.each do |invoice|
      invoice.paid_at = Time.now
      invoice.paid!
    end

    click_link_or_button 'Delete account'
    accept_alert
    assert_current_path new_user_session_path

    assert_text 'You have been logged out and your account has been deleted.'
  end

  def test_destroy_user_with_unpaid_invoices
    sign_in @user_participant
    visit me_path

    click_link_or_button 'Delete account'
    accept_alert

    assert_text 'Your account cannot be deleted because you got unpaid invoices.'
  end

  private

  def sign_in_by_user(user)
    visit new_user_session_path

    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password123'

    within '#password-sign-in' do
      click_link_or_button 'Sign in'
    end
  end
end