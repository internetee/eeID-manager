require 'test_helper'

class AuthTaraIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true

    @new_user_hash = {
      'provider' => 'tara',
      'uid' => 'EE51007050604',
      'info' => {
        'first_name' => 'User',
        'last_name' => 'OmniAuth',
        'name' => 'EE51007050604',
      },
    }

    @tampered_user_hash = {
      provider: 'fake_tara',
      uid: 'fake_uid',
      given_names: 'User',
      country_code: 'EE',
      surname: 'OmniAuth',
      identity_code: '60001019906',
    }
  end

  def test_tara_callback_tampering
    OmniAuth.config.mock_auth[:tara] = OmniAuth::AuthHash.new(@new_user_hash)

    get tara_callback_path
    assert_response :ok

    post tara_create_path(user: @tampered_user_hash)
    refute session[:omniauth_hash]
    assert_redirected_to root_path
  end

  def test_tara_cancel
    get tara_cancel_path
    assert_redirected_to root_path
  end
end