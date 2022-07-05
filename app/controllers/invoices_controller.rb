class InvoicesController < ApplicationController
  before_action :authenticate_user!
  # GET /invoices
  def index
    @transactions = current_user.transactions.order(created_at: :desc)
                                .all.page(params[:transactions_page]).per(5)
    @invoices = current_user.invoices.where(status: 'paid').order(created_at: :desc)
                            .all.page(params[:invoices_page]).per(5)
  end

  def create
    amount =  Money.from_amount(params[:amount].to_d, 'EUR').cents
    invoice = Invoice.by_top_up_request(user: current_user, cents: amount)
    if invoice.save
      payment_order = PaymentOrder.new_from_invoice(invoice.reload)
      payment_order.save!
      respond_to do |format|
        format.html { redirect_to payment_order.reload.linkpay_url }
        format.json { render :show, status: :created, location: payment_order }
      end
    else
      redirect_to(invoices_path, notice: invoice.errors)
    end
  end

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
end
