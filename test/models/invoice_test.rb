require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def setup
    travel_to Time.parse('2010-07-05').in_time_zone
    @user = users(:customer)
    @payable_invoice = invoices(:payable)
    @orphaned_invoice = invoices(:orphaned)
    @service = services(:one)
  end

  def teardown
    travel_back
  end

  def test_price_is_a_money_object
    invoice = Invoice.new(cents: 1000)

    assert_equal Money.new(1000, 'EUR'), invoice.price

    invoice.cents = nil
    assert_equal Money.new(0, 'EUR'), invoice.price
  end

  def test_copy_billing_address_from_user
    invoice = Invoice.new(user: @user,
                          cents: 1000,
                          description: 'test',
                          issue_date: Time.now - 1.day,
                          due_date: Time.now + 1.day)
    assert_not_equal @user.billing_recipient, invoice.recipient
    assert_not_equal @user.billing_vat_code, invoice.vat_code
    assert_not_equal @user.billing_alpha_two_country_code, invoice.country_code
    assert_not_equal @user.billing_street, invoice.street
    assert_not_equal @user.billing_city, invoice.city
    assert_not_equal @user.billing_zip, invoice.postal_code

    invoice.copy_billing_address_from_user

    assert_equal @user.billing_recipient, invoice.recipient
    assert_equal @user.billing_vat_code, invoice.vat_code
    assert_equal @user.billing_alpha_two_country_code, invoice.country_code
    assert_equal @user.billing_street, invoice.street
    assert_equal @user.billing_city, invoice.city
    assert_equal @user.billing_zip, invoice.postal_code
  end

  def test_by_top_up_request
    invoice = Invoice.by_top_up_request(user: @user, cents: 1000)

    assert_equal invoice.user, @user
    assert_equal invoice.cents, 833
    assert_equal invoice.description, 'Account top up via credit card / banklink'
    assert_equal invoice.issue_date, Time.now
    assert_equal invoice.due_date, Time.now
  end

  def test_generate_address
    assert_equal @payable_invoice.address, 'Baker Street 221B, NW1 6XE London, United Kingdom'
  end

  def test_overdue_invoice
    @payable_invoice.update(due_date: Time.now - 1.day)
    @payable_invoice.reload
    assert @payable_invoice.overdue?

    @payable_invoice.update(due_date: Time.now + 1.day)
    @payable_invoice.reload
    refute @payable_invoice.overdue?
  end

  def test_mark_as_paid_at_with_payment_order
    stub_request(:any, /#{API_ENDPOINT}.*/)

    @service.suspend!

    assert_nil @payable_invoice.paid_at
    assert_equal @payable_invoice.vat_rate, 0.0
    assert_nil @payable_invoice.paid_amount
    assert_nil @payable_invoice.paid_with_payment_order

    @payable_invoice.mark_as_paid_at_with_payment_order(Time.now, payment_orders(:issued))
    assert_equal @payable_invoice.paid_at, Time.parse('2010-07-05').in_time_zone
    assert_equal @payable_invoice.vat_rate, 0.0
    assert_equal @payable_invoice.paid_amount, 0.1e2
    assert_equal @payable_invoice.paid_with_payment_order, payment_orders(:issued)

    last_email = ActionMailer::Base.deliveries.last
    assert_match 'credited!', last_email.subject

    refute @user.services.first&.suspended?
  end

  def test_cents_must_be_an_integer
    invoice = prefill_invoice
    invoice.cents = 10.00

    refute invoice.valid?

    assert_equal ['must be an integer'], invoice.errors[:cents]
  end

  def test_filename
    assert_match(/invoice-no-\d+/, @payable_invoice.filename)

    invoice = prefill_invoice
    refute invoice.filename
  end

  def test_cents_must_be_positive
    invoice = prefill_invoice
    invoice.cents = -1000

    refute invoice.valid?

    assert_equal ['must be greater than 0'], invoice.errors[:cents]
  end

  def test_default_status_is_issued
    invoice = prefill_invoice

    assert_equal 'issued', invoice.status
  end

  def test_paid_at_must_be_present_when_status_is_paid
    @payable_invoice.status = :paid

    refute @payable_invoice.valid?
    assert_equal ["can't be blank"], @payable_invoice.errors[:paid_at]
  end

  def test_invoice_title
    expected_number = @payable_invoice.number
    assert_equal "Invoice no #{expected_number}", @payable_invoice.title

    new_invoice = Invoice.new
    refute new_invoice.title
  end

  def prefill_invoice
    invoice = Invoice.new
    invoice.user = @user
    invoice.issue_date = Time.zone.today
    invoice.due_date = Time.zone.today
    invoice.cents = 1000

    invoice
  end
end
