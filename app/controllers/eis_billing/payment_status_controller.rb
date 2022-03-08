module EisBilling
  class PaymentStatusController < EisBilling::BaseController
    def update
      invoice = ::Invoice.find_by(number: params[:order_reference])

      return unless invoice

      payment_order = PaymentOrder.find_by(invoice_id: invoice.id)

      payment_order.response = params
      payment_order.save

      payment_order.check_linkpay_status

      render status: 200, json: { status: 'ok' }
    end

    private

    def linkpay_params
      params.permit(:order_reference, :payment_reference)
    end
  end
end
