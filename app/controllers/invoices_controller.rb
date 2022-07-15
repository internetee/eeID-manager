class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[create]
  before_action :find_invoice, only: %i[show download]
  # GET /invoices
  def index
    @transactions = current_user.transactions.order(created_at: :desc)
                                .all.page(params[:transactions_page]).per(5)
    @invoices = current_user.invoices.where(status: 'paid').order(created_at: :desc)
                            .all.page(params[:invoices_page]).per(5)
  end

  # rubocop:disable Metrics/MethodLength
  def create
    if @invoice.save
      if Feature.billing_system_integration_enabled?
        @invoice.send_to_billing_system
        url = @invoice.reload.payment_link
      else
        url = @invoice.payment_orders.last.linkpay_url
      end
      respond_to do |format|
        format.html { redirect_to URI.parse(url).to_s }
        format.json { render :show, status: :created, location: @invoice }
      end
    else
      redirect_to(invoices_path, notice: @invoice.errors)
    end
  end
  # rubocop:enable Metrics/MethodLength

  # PUT /invoices/aa450f1a-45e2-4f22-b2c3-f5f46b5f906b
  def update; end

  # GET /invoices/aa450f1a-45e2-4f22-b2c3-f5f46b5f906b
  def show; end

  def download
    pdf = PDFKit.new(render_to_string('common/pdf', layout: false))
    raw_pdf = pdf.to_pdf

    send_data(raw_pdf, filename: @invoice.filename)
  end

  private

  def find_invoice
    @invoice = current_user.invoices.find_by(uuid: params[:uuid])
  end

  def set_invoice
    amount = Money.from_amount(params[:amount].to_d, 'EUR').cents
    @invoice = Invoice.by_top_up_request(user: current_user, cents: amount)
  end
end
