module EisBilling
  class SetInvoiceStatus
    def self.ping_status(invoice)
      response = invoice.get_response_from_billing
      change_status_to_pay(response: response, invoice: invoice) if response[:status] == 'paid'
    end

    def self.change_status_to_pay(response:, invoice:)
      return if response[:everypay_response].nil?

      everypay_response = response[:everypay_response]

      payment_order = PaymentOrder.find_by(invoice_id: invoice.id)

      payment_order.response = everypay_response
      payment_order.save

      payment_order.check_linkpay_status
    end
  end
end
