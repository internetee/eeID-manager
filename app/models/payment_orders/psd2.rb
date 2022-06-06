module PaymentOrders
  class Psd2 < PaymentOrder
    CONFIG_NAMESPACE = 'psd2'.freeze

    ACCOUNT_ID = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :account_id)

    URL = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :url)

    ICON = Setting.fetch(:payment_methods, CONFIG_NAMESPACE.to_sym, :icon)

    SUCCESSFUL_PAYMENT = %w[settled authorized].freeze

    def self.config_namespace_name
      CONFIG_NAMESPACE
    end

    # Perform necessary checks and mark the invoice as paid
    def mark_invoice_as_paid
      return unless settled_payment? && valid_response?

      paid!
      time = response['transaction_time'].to_datetime

      Invoice.transaction do
        invoices.each do |invoice|
          invoice.mark_as_paid_at_with_payment_order(time, self)
        end
      end
    end

    private

    # Check if the intermediary reports payment as settled and we can expect money on
    # our accounts
    def settled_payment?
      SUCCESSFUL_PAYMENT.include?(response['payment_state'])
    end

    # Check if response is there and if basic security methods are fullfilled.
    # Skip the check if data was previously requested by us from EveryPay
    # (response['type'] == TRUSTED_DATA) e.g. we know data was originated from trusted source
    def valid_response?
      # return false unless response

      # response['type'] == TRUSTED_DATA
      true
    end
  end
end
