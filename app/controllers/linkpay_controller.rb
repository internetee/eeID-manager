class LinkpayController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[callback]

  def callback
    save_response
    render status: :ok, json: { status: 'ok' }
  end

  def save_response
    payment_order = PaymentOrder.find_by(uuid: linkpay_params[:order_reference])
    return unless payment_order

    payment_order.response = {
      order_reference: linkpay_params[:order_reference],
      payment_reference: linkpay_params[:payment_reference],
    }
    payment_order.save
    CheckLinkpayStatusJob.set(wait: 1.minute).perform_later(payment_order.id)
    # CheckLinkpayStatusJob.perform_later(payment_order.id)
  end

  private

  def linkpay_params
    params.permit(:order_reference, :payment_reference, linkpay: {})
  end
end
