require 'application_system_test_case'

class ContactsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  def setup
    super
    @user = users(:customer)
    @test_contact = contacts(:two)
    sign_in @user
  end

  def test_visit_contacts_page
    visit_contacts_page
  end

  def test_create_new_default_contact
    create_new_contact
  end

  def test_raise_error_during_creating_new_contact
    visit_contacts_page
    redirect_to_create_new_contact

    fill_in 'contact_name', with: 'Test contact'
    fill_in 'contact_email', with: 'wrong@'
    fill_in 'contact_mobile_phone', with: '+372555555'
    fill_in 'contact_identity_code', with: '123456'

    click_on 'Submit'

    assert_text 'Email is invalid'
    assert page.has_css?('.ui.message')
  end

  def test_update_existing_contact
    visit_contacts_page

    visit edit_contact_path(@test_contact)
    assert_text 'Edit Test contact'

    fill_in 'contact_name', with: 'Awesome contact'
    click_on 'Submit'
    assert_text 'Contact was successfully updated.'
    assert_text 'Awesome contact'
  end

  def test_raise_error_during_updating_contact
    visit_contacts_page

    visit edit_contact_path(@test_contact)
    assert_text 'Edit Test contact'

    fill_in 'contact_email', with: 'wrong@'
    click_on 'Submit'

    assert_text 'Email is invalid'
    assert page.has_css?('.ui.message')
  end

  private

  def create_new_contact
    visit_contacts_page
    redirect_to_create_new_contact
    fill_in_fields_and_create_new_contact
  end

  def visit_contacts_page
    visit contacts_path
    assert_text 'Your Contacts'
    assert page.has_css?('.ui.table.unstackable.fixed')
  end

  def redirect_to_create_new_contact
    el = find(:css, '.ui.button.primary')
    el.click
    assert_text 'Create new contact'
  end

  def fill_in_fields_and_create_new_contact
    fill_in 'contact_name', with: 'Test contact'
    fill_in 'contact_email', with: 'example@test.com'
    fill_in 'contact_mobile_phone', with: '+372555555'
    fill_in 'contact_identity_code', with: '123456'
    check_checkbox('contact[default]')

    click_on 'Submit'

    assert_text 'Contact details'
    assert_text 'Contact was successfully created.'
    assert_text 'Test contact'
    assert page.has_css?('.ui.table.very.basic.stackable.padded')
  end
end