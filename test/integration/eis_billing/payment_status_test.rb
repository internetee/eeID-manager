require 'test_helper'

class PaymentStatusTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @invoice = invoices(:payable)
    @payment_order = payment_orders(:issued)
    @payment_order.update(invoice_id: @invoice.id)
    @payment_order.reload

    sign_in users(:customer)
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  def test_successfully_response_should_update_invoice_status_to_paid
    if Feature.billing_system_integration_enabled?
      payload = {
        "order_reference" => @invoice.number,
        "transaction_time" => Time.zone.now - 2.minute,
        "standing_amount" => @invoice.total,
        "payment_state" => 'settled'
      }

      assert_nil @invoice.paid_at

      put eis_billing_payment_status_path,  params: payload,
        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }

      @invoice.reload

      assert_not_nil @invoice.paid_at
      assert_response :ok
    end
  end
end
