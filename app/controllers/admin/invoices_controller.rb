module Admin
  class InvoicesController < BaseController
    before_action :authenticate_user!

    # GET /invoices
    def index
      @invoices = Invoice.where(status: 'paid').order(created_at: :desc).all.page(params[:page])
    end

    # GET /invoices/aa450f1a-45e2-4f22-b2c3-f5f46b5f906b
    def show
      @invoice = Invoice.find_by!(uuid: params[:id])
    end

    def download
      @invoice = Invoice.find_by!(uuid: params[:id])

      pdf = PDFKit.new(render_to_string('common/pdf', layout: false))
      raw_pdf = pdf.to_pdf

      send_data(raw_pdf, filename: @invoice.filename)
    end
  end
end
