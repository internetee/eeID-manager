require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  setup do
    @transaction = transactions(:two)
    @user = users(:customer)
    @service = services(:one)
    Money.default_currency = 'EUR'
  end

  def test_below_critical_level
    money = Setting.fetch(:billing, :balance_critical_cents)
    refute @transaction.below_critical_level? money + 200, money + 100
    assert @transaction.below_critical_level? money + 100, money - 100
  end

  def test_billable_amount
    assert_equal @transaction.billable_amount, 11
  end
end
