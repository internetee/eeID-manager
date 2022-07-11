# require 'expected_payment_order'

class PaymentOrder < ApplicationRecord
  include Concerns::PaymentOrder::Linkpayable
  include Concerns::HttpRequester

  USER = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :user)

  KEY = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :key)

  ENABLED_METHODS = Setting.fetch(:payment_methods, :enabled_methods)

  enum status: { issued: 'issued',
                 paid: 'paid',
                 cancelled: 'cancelled' }

  validates :user_id, presence: true, on: :create
  validates :type, inclusion: { in: ENABLED_METHODS }

  validate :invoice_cannot_be_already_paid, on: :create

  has_many :invoice_payment_orders, dependent: :destroy
  has_many :invoices, through: :invoice_payment_orders
  belongs_to :user, optional: true

  def self.new_from_invoice(invoice, psd2: true)
    payment_type = psd2 ? 'PaymentOrders::Psd2' : 'PaymentOrders::Sepa'
    payment_order = PaymentOrder.new(user: invoice.user, invoice_id: invoice.id,
                                     invoice_ids: [invoice.id], type: payment_type)
    payment_order.invoices = [invoice]
    payment_order
  end

  # Name of configuration namespace
  def self.config_namespace_name; end

  def invoice_cannot_be_already_paid
    return unless invoices.any?(&:paid?)

    errors.add(:invoice, 'is already paid')
  end

  def channel
    type.gsub('PaymentOrders::', '')
  end

  # def self.supported_methods
  #   enabled = []

  #   ENABLED_METHODS.each do |method|
  #     class_name = method.constantize
  #     raise(Errors::ExpectedPaymentOrder, class_name) unless class_name < PaymentOrder

  #     enabled << class_name
  #   end

  #   enabled
  # end

  def check_linkpay_status
    return if paid?

    unless Feature.billing_system_integration_enabled?
      url = "#{LINKPAY_CHECK_PREFIX}#{response['payment_reference']}?api_username=#{USER}"
      body = basic_auth_get(url: url, username: USER, password: KEY)
      return unless body

      update(response: body.merge(type: TRUSTED_DATA, timestamp: Time.zone.now))
    end
    mark_invoice_as_paid
  end
end
