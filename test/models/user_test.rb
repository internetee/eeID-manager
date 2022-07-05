require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: 'email@example.com',
      password: 'email@example.com',
      password_confirmation: 'email@example.com',
      surname: 'Surname',
      given_names: 'Given Names',
      mobile_phone: '+372500100300',
      identity_code: '51007050687',
      country_code: 'EE',
      accepts_terms_and_conditions: true,
      billing_recipient: 'Given Names',
      billing_vat_code: '0002',
      billing_street: 'George Villiage',
      billing_city: 'Brooklyn',
      billing_zip: '0002',
      billing_alpha_two_country_code: 'FI'
    )
  end

  def test_valid_user
    assert @user.valid?
  end

  def test_required_fields
    user = User.new

    refute user.valid?
    assert_equal(["can't be blank"], user.errors[:password])
    assert_equal(["can't be blank"], user.errors[:email])
    # assert_equal(["can't be blank", 'is invalid'], user.errors[:mobile_phone])
    assert_equal(['Terms and conditions must be accepted'], user.errors[:terms_and_conditions])
    assert_equal(["can't be blank"], user.errors[:given_names])
    assert_equal(["can't be blank"], user.errors[:surname])
    assert_equal(["can't be blank"], user.errors[:billing_recipient])
    assert_equal(["can't be blank"], user.errors[:billing_street])
    assert_equal(["can't be blank"], user.errors[:billing_city])
    assert_equal(["can't be blank"], user.errors[:billing_zip])
    assert_equal(["can't be blank"], user.errors[:billing_alpha_two_country_code])
  end

  def test_vat_rate_if_not_estonian_and_billing_vat_code_present
    @user.country_code = 'PL'
    assert @user.valid?
    assert_equal(@user.vat_rate, 0.0)
  end

  def test_vat_rate_if_not_estonian_and_billing_vat_code_not_present
    @user.country_code = 'PL'
    @user.billing_vat_code = ''
    assert @user.valid?
    assert_equal(@user.vat_rate, Countries.vat_rate_from_alpha2_code(@user.country_code))
  end

  def test_identity_code_can_be_empty_if_not_estonian
    @user.country_code = 'PL'
    @user.identity_code = nil
    assert @user.valid?
  end

  def test_identity_code_invalid_if_estonian_and_wrong
    @user.identity_code = '97812120009'
    refute @user.valid?
  end

  def test_invalid_with_unsafe_values
    @user.surname = '"><svg/onload=confirm(1)>'
    @user.given_names = '-sleep(10)#'
    refute @user.valid?
  end

  def test_invalid_with_wrong_password_confirmation
    @user.password = 'password'
    @user.password_confirmation = 'not matching'

    refute @user.valid?
    assert_equal ["doesn't match Password"], @user.errors[:password_confirmation]
  end

  def test_invalid_with_non_unique_email
    new_user = users(:customer).dup
    refute new_user.valid?
    assert_equal ['has already been taken'], new_user.errors[:email]
  end

  def test_invalid_with_identity_code_non_unique_for_a_country
    new_user = users(:customer).dup
    refute new_user.valid?
    assert_equal ['has already been taken'], new_user.errors[:identity_code]
  end

  def test_country_code_is_an_alias
    @user.alpha_two_country_code = 'EE'
    assert_equal 'EE', @user.country_code
  end

  def test_signed_in_with_identity_document
    refute @user.signed_in_with_identity_document?

    @user.provider = User::TARA_PROVIDER
    refute @user.signed_in_with_identity_document?

    @user.uid = 'EE1234'
    assert @user.signed_in_with_identity_document?
  end

  def test_requires_captcha
    assert @user.requires_captcha?

    @user.provider = User::TARA_PROVIDER
    @user.uid = 'EE1234'

    refute @user.requires_captcha?
  end

  def test_invalid_with_country_code_not_two_letters_long
    @user.country_code = 'EST'
    assert_raise ActiveRecord::ValueTooLong do
      @user.save
    end
  end

  def test_display_name
    @user.given_names = 'New Given Name'
    assert_equal 'New Given Name Surname', @user.display_name
  end

  def test_accepts_terms_and_conditions_are_only_updated_when_needed
    customer = users(:customer)
    original_terms_and_conditions_accepted_at = customer.terms_and_conditions_accepted_at
    customer.update(accepts_terms_and_conditions: true)

    assert_equal original_terms_and_conditions_accepted_at,
                 customer.terms_and_conditions_accepted_at

    customer.update(accepts_terms_and_conditions: false)
    customer.update(accepts_terms_and_conditions: true)

    assert_not_equal original_terms_and_conditions_accepted_at,
                     customer.terms_and_conditions_accepted_at
  end

  def test_has_default_role
    assert_equal [User::CUSTOMER_ROLE], @user.roles
    assert @user.role?(User::CUSTOMER_ROLE)
    refute @user.role?(User::ADMINISTRATOR_ROLE)
  end

  def test_admin_scope
    assert_includes User.admins, users(:administrator)
    refute_includes User.admins, users(:customer)
  end
end
