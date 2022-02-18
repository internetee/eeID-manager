require 'test_helper'

class SafeValueValidatorTest < ActiveSupport::TestCase
  def setup
    @user = User.new
    @user.surname = '"><svg/onload=confirm(1)>'
    @user.given_names = 'Given Names ÖÄÕÜüõöä'
  end

  def test_validate_mock_data_from_tara
    @user.given_names = 'MARY ÄNN'
    @user.surname = 'O’CONNEŽ-ŠUSLIK TESTcNUMBER'

    validator = SafeValueValidator.new(
      { attributes: { surname: @user.surname,
                      given_names: @user.given_names } }
    )
    assert validator.validate_each(@user, :surname, @user.surname)
    assert validator.validate_each(@user, :given_names, @user.given_names)
  end

  def test_false_on_invalid_values
    validator = SafeValueValidator.new(
      { attributes: { surname: @user.surname } }
    )
    refute validator.validate_each(@user, :surname, @user.surname)
  end

  def test_true_on_valid_values
    validator = SafeValueValidator.new(
      { attributes: { given_names: @user.given_names } }
    )
    assert validator.validate_each(@user, :given_names, @user.given_names)
  end
end

