require 'test_helper'

class PaymentOrderTest < ActiveSupport::TestCase
  def setup
    @payable_invoice = invoices(:payable)
    @payment_order = payment_orders(:issued)
    @user = users(:customer)
  end

  def test_required_fields
    payment_order = PaymentOrder.new
    refute payment_order.valid?

    payment_order.invoices << @payable_invoice
    payment_order.user = @user
    payment_order.type = 'PaymentOrders::Psd2'

    assert(payment_order.valid?, payment_order.errors.full_messages)
  end

  def test_default_status_is_issued
    payment_order = PaymentOrder.new
    assert_equal PaymentOrder.statuses[:issued], payment_order.status
  end

  def test_allowed_types_are_taken_from_config
    assert_equal ['PaymentOrders::Psd2', 'PaymentOrders::Sepa'], PaymentOrder::ENABLED_METHODS
  end

  def test_payment_method_must_be_supported_for_the_object_to_be_valid
    payment_order = PaymentOrder.new

    payment_order.invoices << @payable_invoice
    payment_order.user = @user
    payment_order.type = 'PaymentOrders::Psd2'

    assert payment_order.valid?

    payment_order.type = 'PaymentOrders::Manual'
    refute payment_order.valid?
  end

  def test_new_from_invoice_psd2
    payment_psd2_order = PaymentOrder.new_from_invoice(@payable_invoice)

    assert_equal payment_psd2_order.type, 'PaymentOrders::Psd2'
    assert payment_psd2_order.invoices.include? @payable_invoice
  end

  def test_new_from_paid_invoice
    paid_invoice = @payable_invoice
    paid_invoice.paid_at = Time.now
    paid_invoice.paid!
    payment_order = PaymentOrder.new_from_invoice(paid_invoice)

    assert_equal payment_order.type, 'PaymentOrders::Psd2'
    assert payment_order.invoices.include? paid_invoice
    refute payment_order.valid?
  end

  def test_payment_order_channel
    assert_equal @payment_order.channel, 'Psd2'
  end
end
