require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:customer)
    sign_in @user
  end

  def test_required_fields
    contact = Contact.new

    refute contact.valid?
    assert_equal(["can't be blank"], contact.errors[:name])
    assert_equal(["can't be blank", 'is invalid'], contact.errors[:email])

    contact.email = 'email@example.com'
    contact.name = 'Test test'
    contact.identity_code = '12345678'
    contact.user = @user

    assert contact.valid?
  end
end
