require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  def setup
    @service = services(:one)
    stub_request(:any, "#{API_ENDPOINT}/clients/#{@service.regex_service_name}")
  end

  def teardown
    ActionMailer::Base.deliveries.clear
  end

  def test_valid_service
    assert @service.valid?
  end

  def test_required_fields
    service = Service.new
    refute service.valid?
    assert_equal(["can't be blank"], service.errors[:name])
    assert_equal(["can't be blank"], service.errors[:short_description])
    assert_equal(["can't be blank"], service.errors[:approval_description])
    assert_equal(["can't be blank", 'is invalid'], service.errors[:callback_url])
  end

  def test_invalid_without_name
    @service.name = nil
    refute @service.valid?, 'saved service without a name'
    assert_not_nil @service.errors[:name], 'no validation error for name present'
  end

  def test_callback_uri
    @service.callback_url = ''
    refute @service.valid?
    assert @service.errors.messages[:callback_url].include? 'is invalid'
  end

  def test_service_statuses
    @service.update(rejected: true, approved: false, suspended: false)
    assert_equal @service.status, 'REJECTED'

    @service.update(archived: true)
    assert_equal @service.status, 'ARCHIVED'

    @service.update(archived: false, rejected: false)
    assert_equal @service.status, 'AWAITING_APPROVAL'

    @service.update(approved: true, suspended: true)
    assert_equal @service.status, 'SUSPENDED'

    @service.update(suspended: false)
    assert_equal @service.status, 'ACTIVE'

    @service.update(rejected: true)
    assert_equal @service.status, 'REJECTED'
  end

  def test_reject_service
    @service.reject!

    assert @service.rejected?
    refute @service.approved?
    assert_nil @service.client_id
    last_email = ActionMailer::Base.deliveries.last
    assert_match @service.name, last_email.subject
  end

  def test_suspend_service
    @service.approved = false
    @service.suspend!(no_credit: false)

    refute @service.suspended?
    @service.approved = true
    @service.suspend!(no_credit: false)
    assert @service.suspended?
  end

  def test_unsuspend_service
    @service.suspended = true
    @service.unsuspend!
    refute @service.suspended?
  end

  def test_unsuspend_service_with_user_out_of_balance
    @service.suspended = true
    @service.user&.balance_cents = 1
    assert_raise StandardError do
      @service.unsuspend!
    end
    assert @service.suspended?
  end

  def test_archive_service
    assert @service.client_id.present?
    @service.archive!
    assert @service.archived?
    assert_nil @service.client_id
  end
end
