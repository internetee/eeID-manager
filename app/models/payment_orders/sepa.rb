module PaymentOrders
  class Sepa < PaymentOrder
    CONFIG_NAMESPACE = 'sepa'.freeze

    # def self.config_namespace_name
    #   CONFIG_NAMESPACE
    # end

    # Perform necessary checks and mark the invoice as paid
    def mark_invoice_as_paid
      paid!
      Invoice.transaction do
        invoices.each do |invoice|
          invoice.mark_as_paid_at_with_payment_order(Time.now, self)
        end
      end
    end
  end
end
