require 'test_helper'

class AdminInvoicesIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @invoice = invoices(:payable)
    sign_in users(:administrator)
  end

  def test_show_method_specific_invoice
    get admin_invoice_path(@invoice.uuid)

    assert_response :ok
  end

  def test_download
    get download_admin_invoice_url(@invoice.uuid)

    assert_response :ok
		assert_equal 'application/pdf', response.headers['Content-Type']
    assert_equal "attachment; filename=\"invoice-no-#{@invoice.number}.pdf\"; filename*=UTF-8''invoice-no-#{@invoice.number}.pdf", response.headers['Content-Disposition']
    assert_not_empty response.body
  end
end