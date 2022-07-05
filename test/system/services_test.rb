require 'application_system_test_case'

class ServicesTest < ApplicationSystemTestCase
  def setup
    super
    @user = users(:customer)
    @service_one = services(:one)
    sign_in @user
  end

  def test_visit_services_page
    visit_services_page
  end

  def test_create_new_service
    create_new_service
  end

  def test_create_new_service_without_user_main_contact
    @user.contacts.destroy_all
    create_new_service
  end

  def test_raise_error_during_creating_new_service
    visit_services_page
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
    visit_services_page

    assert_text 'Test service'
    click_link 'Test service'
    click_link 'Edit service details'

    fill_in 'service_name', with: 'Awesome service'
    click_on 'Update'
    assert_text 'Service was successfully updated.'
    assert_text 'Awesome service'
  end

  def test_update_active_service_with_no_hydra_client
    stub_put_hydra_client_not_ok

    visit edit_service_path(@service_one)

    fill_in 'service_name', with: 'Awesome service'
    click_on 'Update'
    assert_text '404 Not Found'
  end

  def test_update_active_service_with_no_hydra_server_connection
    stub_put_hydra_client_with_socket_error

    visit edit_service_path(@service_one)

    fill_in 'service_name', with: 'Awesome service'
    click_on 'Update'
    assert_text 'Failed to open TCP connection to hydra'
    assert_current_path root_path
  end

  def test_update_approved_service_not_important_attributes
    stub_request(:any, /#{API_ENDPOINT}.*/)

    visit edit_service_path(@service_one)

    fill_in 'service_name', with: 'Awesome service'
    click_on 'Update'
    assert_text 'Service was successfully updated.'
    assert_text 'Awesome service'
    assert_text 'ACTIVE'
  end

  def test_update_approved_service_important_attributes
    stub_request(:any, /#{API_ENDPOINT}.*/)

    visit edit_service_path(@service_one)

    fill_in 'service_callback_url', with: 'https://another_callback_url'
    click_on 'Update'

    assert_text 'Service was successfully updated.'
    assert_text 'AWAITING_APPROVAL'
    assert page.has_css?('.ui.message')
  end

  def test_raise_error_during_update_service
    create_new_service
    visit_services_page

    assert_text 'Test service'
    click_link 'Test service'
    click_link 'Edit service details'

    fill_in 'service_callback_url', with: 'Awesome service'
    click_on 'Update'

    assert_text 'Callback url is invalid'
    assert page.has_css?('.ui.message')
  end

  def test_destroy_new_created_service
    stub_request(:any, /#{API_ENDPOINT}.*/)

    create_new_service
    visit_services_page

    assert_text 'Test service'
    click_link 'Test service'
    click_link 'Delete'
    accept_alert

    assert_text 'Service was successfully destroyed.'
    assert_no_text 'Test service'
  end

  private

  def create_new_service
    visit_services_page
    redirect_to_create_new_service
    fill_in_fields_and_create_new_service
  end

  def visit_services_page
    visit services_path
    assert_text 'Your eeID Services'
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