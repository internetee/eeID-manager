class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :authentication
  before_save :attach_transaction_cost
  after_save :update_user_balance

  def billable_amount
    net_price = Setting.fetch(:billing, :auth_price)
    Money.new(net_price + user.vat_rate * net_price).cents
  end

  def update_user_balance
    balance = user.balance_cents
    return unless user.update(balance_cents: balance - billable_amount)

    user.balance_critical! if below_critical_level?(balance, user.balance_cents)
    user.suspend_services! if user.balance_cents < billable_amount
  end

  def attach_transaction_cost
    return unless cents.nil?

    self.cents = billable_amount
  end

  def below_critical_level?(before, after)
    critical_cents = Setting.fetch(:billing, :balance_critical_cents) || 500

    before >= critical_cents && after < critical_cents
  end
end
