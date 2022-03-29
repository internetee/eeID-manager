require 'test_helper'

class ContactsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  API_ENDPOINT = EidManager::Application.config.customization.dig(:tara, :ory_hydra_private)

  setup do
    @user = users(:customer)
    sign_in @user
    stub_request(:any, /#{API_ENDPOINT}.*/)
  end

  def test_test_forbidding_destroy_contact_used_by_service
    assert_equal @user.contacts.count, 2

    contact = contacts(:john)

    assert_no_difference '@user.contacts.count' do
      delete contact_path(contact)
    end

    contact.services.first.archive!
    assert_difference '@user.contacts.count', -1, 'A Contact should be destroyed' do
      delete contact_path(contact)
    end
  end
end
