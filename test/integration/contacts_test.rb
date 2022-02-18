require 'test_helper'

class ContactsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:customer)
    sign_in @user
    stub_request(:any, /#{API_ENDPOINT}.*/)
  end

  def test_test_forbidding_destroy_contact_used_by_service
    assert_equal @user.contacts.count, 2
    contact = contacts(:john)
    delete contact_path(contact)

    assert_equal @user.contacts.count, 2

    contact.services.first.archive!
    delete contact_path(contact)

    assert_equal @user.contacts.count, 1
  end
end
