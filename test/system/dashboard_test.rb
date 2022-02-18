require 'application_system_test_case'

class DashboardTest < ApplicationSystemTestCase
  def test_dashboard_page
    sign_in users(:customer)
    visit dashboard_path
    assert_text 'Dashboard'
    assert page.has_css?('.ui.table.unstackable')
  end
end