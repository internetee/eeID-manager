require 'application_system_test_case'

class InvoicesTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper
  include Devise::Test::IntegrationHelpers
  def setup
    @user = users(:customer)
    @payment_order = payment_orders(:issued)
    @invoice = @payment_order.invoices.first
    sign_in @user
  end

  def test_visit_invoices_page
    visit invoices_path
    assert_text 'Billing'
    assert page.has_css?('.ui.selectable.stackable.table')
  end
end