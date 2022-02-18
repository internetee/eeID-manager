require 'test_helper'

class Psd2Test < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  CONFIG_NAMESPACE = 'psd2'.freeze

  LINKPAY_CHECK_PREFIX = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :linkpay_check_prefix)

  USER = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :user)

  def setup
    @payment_order = payment_orders(:issued)
    @invoice = @payment_order.invoices.first
  end

  def test_marks_invoice_as_paid_successfully
    @payment_order.update(response: callback_params)
    url = "#{LINKPAY_CHECK_PREFIX}#{callback_params['payment_reference']}?api_username=#{USER}"
    stub_request(:get, url).to_return(status: 200, body: every_pay_payment_outcome_response)

    body = JSON.parse(every_pay_payment_outcome_response).with_indifferent_access
    @payment_order.response = body.merge(type: 'trusted_data', timestamp: Time.zone.now)
    @payment_order.mark_invoice_as_paid
    @invoice.reload
    assert @payment_order.paid?
    assert @invoice.paid?
  end
  # rubocop:disable all
  def callback_params
    {
      "order_reference"=>@invoice.number,
      "payment_reference"=>"1b1ee0cad31038ab000ddd0f021487711d88db9418a3ca53672e223337037c7d"
    }
  end

  def every_pay_payment_outcome_response
    { "account_name"=> PaymentOrders::Psd2::ACCOUNT_ID,
      "order_reference"=> @invoice.number,
      "email"=>nil,
      "customer_ip"=>"127.0.0.1",
      "customer_url"=>"https://test-tara-billing.infra.tld.ee/payment_orders/#{@payment_order.uuid}/return",
      "payment_created_at"=>"2021-03-24T11:27:45.501Z",
      "initial_amount"=> Money.new(@invoice.total, 'EUR').to_d,
      "standing_amount"=> Money.new(@invoice.total, 'EUR').to_d,
      "payment_reference"=>"1b1ee0cad31038ab000ddd0f021487711d88db9418a3ca53672e223337037c7d",
      "payment_link"=>"https://igw-demo.every-pay.com/lp/knnoon/gV9tJMZF",
      "api_username"=> PaymentOrders::Psd2::USER,
      "warnings"=>{},
      "stan"=>540332,
      "fraud_score"=>0,
      "payment_state"=>"settled",
      "payment_method"=>"lhv_ob_ee",
      "ob_details": {
        "debtor_iban"=>"EE717700771001735865",
        "creditor_iban"=>"EE168938346545967075",
        "ob_payment_reference"=>"14a29c8a-dd6d-4e7b-8921-0a26c4713652",
        "ob_payment_state"=>"ACSC"
      },
      "transaction_time"=>"2021-03-24T11:27:58.084Z"
    }.to_json
  end
  # rubocop:enable all
end