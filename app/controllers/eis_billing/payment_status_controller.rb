module EisBilling
  class PaymentStatusController < EisBilling::BaseController
    def update
      invoice = ::Invoice.find_by(number: params[:order_reference])

      return unless invoice

      payment_order = PaymentOrder.find_by(invoice_id: invoice.id)

      payment_order.response = params
      payment_order.save

      payment_order.check_linkpay_status

      # render status: :ok, json: { status: 'ok' }
      respond_to do |format|
        format.json do
          render status: :ok, content_type: 'application/json', layout: false, json: { message: 'ok' }
        end
      end
    end

    private

    def linkpay_params
      params.permit(:order_reference, :payment_reference)
    end
  end
end
