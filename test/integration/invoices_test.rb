require 'test_helper'

class InvoicesIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:customer)
    @invoice = invoices(:payable)
    sign_in @user
  end

  def test_download_invoice
    get download_invoice_url(@invoice.uuid)

    assert_response :ok
		assert_equal 'application/pdf', response.headers['Content-Type']
    assert_equal "attachment; filename=\"invoice-no-#{@invoice.number}.pdf\"; filename*=UTF-8''invoice-no-#{@invoice.number}.pdf", response.headers['Content-Disposition']
    assert_not_empty response.body
  end

  def test_create_invoice_with_errors
    # response = post invoices_url
    # buf=["<html><body>You are being <a href=\"http://www.example.com/invoices\">redirected</a>.</body></html>"]
    post invoices_url(user: @user, cents: 10_000)
    assert_redirected_to invoices_url
  end

  def test_create_invoice
    post invoices_url(user: @user, amount: 200)
    last_payment_order = PaymentOrder.last

    assert_redirected_to last_payment_order.linkpay_url
  end

  def test_show_current_invoice
    get invoice_url(uuid: @invoice.uuid)
    assert_response :ok
  end
end
