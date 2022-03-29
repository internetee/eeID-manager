require 'application_system_test_case'

class ServicesTest < ApplicationSystemTestCase
  def setup
    super
    @user = users(:customer)
    @service = services(:one)
    sign_in @user
  end

  def test_visit_authentication_page
    visit_authentication_page
  end

  def test_create_new_service
    create_new_service
  end

  def test_raise_error_during_creating_new_service
    visit_authentication_page
    redirect_to_create_new_service

    fill_in 'service_name', with: 'Test service'
    fill_in 'service_short_description', with: 'Test description'
    fill_in 'service_approval_description', with: 'Test detailed description'
    fill_in 'service_callback_url', with: 'wer'

    click_on 'Submit for approval'

    assert_text 'Callback url is invalid'
    assert page.has_css?('.ui.message')
  end

  def test_update_new_service
    stub_request(:any, /#{API_ENDPOINT}.*/)

    create_new_service
    visit_authentication_page

    assert_text 'Test service'
    click_link 'Test service'
    click_link 'Edit service details'

    fill_in 'service_name', with: 'Awesome service'
    click_on 'Submit for approval'
    assert_text 'Service was successfully updated.'
    assert_text 'Awesome service'
  end

  def test_update_approved_service_not_important_attributes
    stub_request(:any, /#{API_ENDPOINT}.*/)

    visit services_path
    assert_text 'One'
    assert_text 'ACTIVE'
    click_link 'One'
    click_link 'Edit service details'

    fill_in 'service_name', with: 'Awesome service'
    click_on 'Submit for approval'
    assert_text 'Service was successfully updated.'
    assert_text 'Awesome service'
    assert_text 'ACTIVE'
  end

  def test_update_approved_service_important_attributes
    stub_request(:any, /#{API_ENDPOINT}.*/)

    visit services_path

    assert_text 'One'
    assert_text 'ACTIVE'
    click_link 'One'
    click_link 'Edit service details'

    fill_in 'service_callback_url', with: 'https://another_callback_url'
    click_on 'Submit for approval'

    assert_text 'Service was successfully updated.'
    assert_text 'AWAITING_APPROVAL'
    assert page.has_css?('.ui.message')
  end

  def test_raise_error_during_update_service
    create_new_service
    visit_authentication_page

    assert_text 'Test service'
    click_link 'Test service'
    click_link 'Edit service details'

    fill_in 'service_callback_url', with: 'Awesome service'
    click_on 'Submit for approval'

    assert_text 'Callback url is invalid'
    assert page.has_css?('.ui.message')
  end

  def test_destroy_new_created_service
    stub_request(:any, /#{API_ENDPOINT}.*/)

    create_new_service
    visit_authentication_page

    assert_text 'Test service'
    click_link 'Test service'
    click_link 'Delete'
    accept_alert

    assert_text 'Service was successfully destroyed.'
    assert_no_text 'Test service'
  end

  private

  def create_new_service
    visit_authentication_page
    redirect_to_create_new_service
    fill_in_fields_and_create_new_service
  end

  def visit_authentication_page
    visit services_path
    assert_text 'Your eID Services'
    assert page.has_css?('.ui.table.unstackable.fixed')
  end

  def redirect_to_create_new_service
    el = find(:css, '.ui.button.primary')
    el.click
    assert_text 'Create new service'
  end

  def fill_in_fields_and_create_new_service
    fill_in 'service_name', with: 'Test service'
    fill_in 'service_short_description', with: 'Test description'
    fill_in 'service_approval_description', with: 'Test detailed description'
    fill_in 'service_callback_url', with: 'http://testawesomesite.ee'

    click_on 'Submit for approval'

    assert_text 'Service details'
    assert_text 'Test service'
    assert page.has_css?('.ui.table.very.basic.stackable.padded')
  end
end