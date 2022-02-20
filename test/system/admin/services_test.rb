require 'application_system_test_case'

class ServicesAdminTest < ApplicationSystemTestCase
  def setup
    super
    @user = users(:administrator)
    @service_one = services(:one)
    sign_in @user
  end

  def test_visit_services_page
    visit_services_page
  end

  def test_visit_unapproved_service
    stub_hydra_client_does_not_exist

    @service_one.update(approved: false)

    visit_specific_service('One')

    assert_text 'AWAITING_APPROVAL'
  end

  def test_visit_approved_service
    stub_hydra_requests_ok

    visit_specific_service('One')

    assert @service_one.approved
    assert_not_nil @service_one.client_id
    assert_text 'ACTIVE'
  end

  def test_suspend_unsuspend_active_service
    stub_hydra_requests_ok

    visit_specific_service('One')

    assert_text 'ACTIVE'
    click_on 'Suspend service'
    accept_alert
    assert_text 'Service successfully suspended!'
    assert_text 'SUSPENDED'

    click_on 'Unsuspend service'
    accept_alert
    assert_text 'Service successfully unsuspended!'
    assert_text 'ACTIVE'
  end

  def test_approve_service
    stub_hydra_client_does_not_exist
    stub_post_hydra_client_ok

    @service_one.update(client_id: nil, approved: false, archived: false, rejected: false)

    visit_specific_service('One')

    assert_text 'AWAITING_APPROVAL'

    click_link_or_button 'Approve and bind'
    assert_text 'Service successfully approved and binded!'
    assert_text 'ACTIVE'
  end

  def test_reject_awaiting_approval_service
    stub_hydra_client_does_not_exist

    @service_one.update(client_id: nil, approved: false, archived: false, rejected: false)

    visit_specific_service('One')

    assert_text 'AWAITING_APPROVAL'

    click_link_or_button 'Reject'
    accept_alert
    assert_text 'Service successfully rejected!'
  end

  private

  def visit_specific_service(name_of_service)
    visit_services_page

    click_link name_of_service
    assert_text 'Service details'
    assert_text name_of_service
  end

  def visit_services_page
    visit admin_services_path
    assert_text 'Services'
  end
end