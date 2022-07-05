require 'application_system_test_case'

# https://github.com/internetee/auction_center/blob/master/test/system/users/tara_users_test.rb

class TaraTest < ApplicationSystemTestCase
  def setup
    super
    ActionMailer::Base.deliveries.clear

    OmniAuth.config.test_mode = true

    @user = users(:signed_in_with_omniauth)

    @existing_user_hash = {
      'provider' => @user.provider,
      'uid' => @user.uid,
      'info' => {
        'first_name' => @user.given_names,
        'last_name' => @user.surname,
        'name' => @user.uid,
      },
    }

    @new_user_hash = {
      'provider' => 'tara',
      'uid' => 'EE51007050604',
      'info' => {
        'first_name' => 'User',
        'last_name' => 'OmniAuth',
        'name' => 'EE51007050604',
      },
    }
  end

  def test_user_can_create_new_account_with_tara
    OmniAuth.config.mock_auth[:tara] = OmniAuth::AuthHash.new(@new_user_hash)

    visit root_path

    within('#tara-sign-in') do
      click_link('Sign in')
    end

    user_uid = find('#user_uid', visible: :all)
    user_last_name = find('#user_surname', visible: :all)
    user_first_name = find('#user_given_names', visible: :all)

    assert_equal user_uid.value, @new_user_hash['uid']
    assert_equal user_first_name.value, @new_user_hash['info']['first_name']
    assert_equal user_last_name.value, @new_user_hash['info']['last_name']

    fill_in 'Email', with: 'tere@test.ee'
    fill_in 'Mobile phone', with: '+37256677889'
    fill_in 'Billed to', with: 'John Joe'
    fill_in 'VAT code', with: '112233445566'
    fill_in 'Street', with: 'Bakery street'
    fill_in 'City', with: 'Tartu'
    fill_in 'Postal code', with: '13001'

    check_checkbox('user[accepts_terms_and_conditions]')

    click_link_or_button('Sign up')

    assert_text 'You have to confirm your email address before continuing.'

    last_email = ActionMailer::Base.deliveries.last
    assert_equal('Confirmation instructions', last_email.subject)
    assert_equal(['tere@test.ee'], last_email.to)

    assert has_current_path? new_user_session_path
  end

  def test_create_new_account_with_tara_with_errors
    OmniAuth.config.mock_auth[:tara] = OmniAuth::AuthHash.new(@new_user_hash)

    visit root_path

    within('#tara-sign-in') do
      click_link('Sign in')
    end

    user_uid = find('#user_uid', visible: :all)
    user_last_name = find('#user_surname', visible: :all)
    user_first_name = find('#user_given_names', visible: :all)

    assert_equal user_uid.value, @new_user_hash['uid']
    assert_equal user_first_name.value, @new_user_hash['info']['first_name']
    assert_equal user_last_name.value, @new_user_hash['info']['last_name']

    fill_in 'Email', with: ''
    fill_in 'Mobile phone', with: '+37256677889'
    fill_in 'Billed to', with: 'John Joe'
    fill_in 'VAT code', with: '112233445566'
    fill_in 'Street', with: 'Bakery street'
    fill_in 'City', with: 'Tartu'
    fill_in 'Postal code', with: '13001'

    check_checkbox('user[accepts_terms_and_conditions]')

    assert_no_difference -> { User.count } do
      click_link_or_button 'Sign up'
    end

    assert_text 'Errors'
    assert_current_path '/auth/tara/create'
  end

  def test_existing_user_gets_signed_in
    OmniAuth.config.mock_auth[:tara] = OmniAuth::AuthHash.new(@existing_user_hash)

    visit root_path

    within('#tara-sign-in') do
      click_link('Sign in')
    end

    assert_text('Signed in successfully')
    assert has_current_path? user_path(@user.uuid)
  end
end