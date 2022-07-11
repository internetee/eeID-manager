class InvoicesController < ApplicationController
  before_action :authenticate_user!
  # GET /invoices
  def index
    @transactions = current_user.transactions.order(created_at: :desc)
                                .all.page(params[:transactions_page]).per(5)
    @invoices = current_user.invoices.where(status: 'paid').order(created_at: :desc)
                            .all.page(params[:invoices_page]).per(5)
  end

  # rubocop:disable Metrics/MethodLength
  def create
    amount =  Money.from_amount(params[:amount].to_d, 'EUR').cents
    invoice = Invoice.by_top_up_request(user: current_user, cents: amount)
    if invoice.save && invoice.reload
      payment_order = create_payment_order_from_invoice!(invoice)
      if Feature.billing_system_integration_enabled?
        send_invoice_to_billing_system(invoice)
        redirect_url = URI.parse(invoice.payment_link).to_s
      else
        redirect_url = URI.parse(payment_order.linkpay_url).to_s
      end
      respond_to do |format|
        format.html { redirect_to redirect_url }
        format.json { render :show, status: :created, location: payment_order }
      end
    else
      redirect_to(invoices_path, notice: invoice.errors)
    end
  end
  # rubocop:enable Metrics/MethodLength

  # PUT /invoices/aa450f1a-45e2-4f22-b2c3-f5f46b5f906b
  def update; end

  # GET /invoices/aa450f1a-45e2-4f22-b2c3-f5f46b5f906b
  def show
    @invoice = current_user.invoices.find_by(uuid: params[:uuid])
  end

  def download
    @invoice = current_user.invoices.find_by(uuid: params[:uuid])

    pdf = PDFKit.new(render_to_string('common/pdf', layout: false))
    raw_pdf = pdf.to_pdf

    send_data(raw_pdf, filename: @invoice.filename)
  end

  private

  def create_payment_order_from_invoice!(invoice)
    payment_order = PaymentOrder.new_from_invoice(invoice)
    payment_order.save!
    payment_order.reload
  end

  def send_invoice_to_billing_system(invoice)
    add_invoice_instance = EisBilling::Invoice.new(invoice)
    result = add_invoice_instance.send_invoice
    link = JSON.parse(result.body)['everypay_link']

    invoice.update(payment_link: link)
  end
end
