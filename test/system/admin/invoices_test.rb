require 'application_system_test_case'

class InvoicesAdminTest < ApplicationSystemTestCase
  def setup
    super
    @user = users(:administrator)
    sign_in @user
  end

  def test_visit_invoices_page
    visit admin_invoices_path
    assert_text 'Payment History'
  end
end