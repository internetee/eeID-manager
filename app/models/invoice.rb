require 'countries'

class Invoice < ApplicationRecord
  alias_attribute :country_code, :alpha_two_country_code
  enum status: { issued: 'issued', paid: 'paid', cancelled: 'cancelled' }
  belongs_to :user, optional: true
  has_many :invoice_payment_orders, dependent: :destroy
  has_many :payment_orders, through: :invoice_payment_orders
  belongs_to :paid_with_payment_order, class_name: 'PaymentOrder', optional: true
  validates :user_id, presence: true, on: :create
  validates :description, presence: true
  validates :issue_date, :due_date, presence: true
  validates :paid_at, presence: true, if: proc { |invoice| invoice.paid? }
  validates :cents, numericality: { only_integer: true, greater_than: 0 }
  before_create :copy_billing_address_from_user

  scope :overdue, -> { where('due_date < ? AND status = ?', Time.zone.today, statuses[:issued]) }

  def self.by_top_up_request(user:, cents:, psd2: true)
    inv = Invoice.new
    inv.user = user
    inv.cents = Money.new(cents / (1 + user.vat_rate), 'EUR').cents
    inv.description = "Account top up via #{psd2 ? 'credit card / banklink' : 'SEPA transfer'}"
    inv.issue_date = Time.now
    inv.due_date = Time.now

    inv
  end

  def copy_billing_address_from_user
    self.recipient = user.billing_recipient
    self.vat_code = user.billing_vat_code
    self.country_code = user.billing_alpha_two_country_code
    self.street = user.billing_street
    self.city = user.billing_city
    self.postal_code = user.billing_zip
  end

  def price
    Money.new(cents, 'EUR')
  end

  def total
    price * (1 + vat_rate)
  end

  def vat
    price * vat_rate
  end

  def title
    persisted? ? "Invoice no #{number}" : nil
  end

  def address
    country_name = Countries.name_from_alpha2_code(country_code)
    postal_code_with_city = [postal_code, city].join(' ')
    [street, postal_code_with_city, country_name].compact.join(', ')
  end

  def vat_rate
    return Countries.vat_rate_from_alpha2_code(country_code) if country_code == 'EE'
    return BigDecimal('0') if vat_code.present?

    Countries.vat_rate_from_alpha2_code(country_code)
  end

  def filename
    return unless title

    "#{title.parameterize}.pdf"
  end

  # mark_as_paid_at_with_payment_order(time, payment_order) is the preferred version to use
  # in the application, but this is also used with administrator manually setting invoice as
  # paid in the user interface.
  # def mark_as_paid_at(time)
  #   ActiveRecord::Base.transaction do
  #     self.paid_at = time
  #     self.vat_rate = vat_rate
  #     self.paid_amount = total

  #     paid!
  #     result.mark_as_payment_received(time)
  #   end
  # end

  def mark_as_paid_at_with_payment_order(time, payment_order)
    ActiveRecord::Base.transaction do
      self.paid_at = time
      self.vat_rate = vat_rate
      self.paid_amount = total
      self.paid_with_payment_order = payment_order

      update_user_balance if paid!
    end
  end

  def overdue?
    due_date < Time.zone.today && issued?
  end

  def update_user_balance
    balance = user.balance_cents
    user.balance_cents = balance + Money.new(total, 'EUR').cents
    return unless user.update(balance_cents: balance + Money.new(total, 'EUR').cents)

    BillingMailer.account_credited(user, self).deliver_later
    user.unsuspend_services!
  end
end
