module Admin
  class ServicesController < BaseController
    include OrderableHelper
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token, only: [:cors_preflight_check]
    before_action :set_service, only: %i[show edit update download_service_file destroy]

    def index
      @unapproved_services = Service.unarchived.where(approved: false, rejected: false).all.page(params[:unapproved_page]).per(10)
      @rejected_services = Service.unarchived.where(rejected: true).all
      @services = Service.unarchived.where(approved: true).where(rejected: false).all.page(params[:services_page]).per(20)
    end

    def show
      @user = @service.user
      @hydra_client = @service.find_hydra_client
      @hydra_client_present = !@hydra_client.nil?
      respond_to do |format|
        format.html
        format.xlsx {
          response.headers[
            'Content-Disposition'
          ] = "attachment; filename=client_#{@service.id}.xlsx"
        }
      end
    end

    def edit; end

    def update
      if params['approve']
        process_service_approval
      elsif params['suspend']
        process_service_suspension
      end
    end

    def process_service_approval
      respond_to do |format|
        case params['approve']
        when 'true'
          begin
            @service.approve!
            format.html { redirect_to(admin_service_path(@service), notice: "Service successfully approved and binded!") }
          rescue RestClient::ExceptionWithResponse => e
            format.html { redirect_to(admin_service_path(@service), notice: e.error) }
          end
        when 'false'
          begin
            @service.reject!
            format.html { redirect_to(admin_services_path, notice: 'Service successfully rejected!') }
          rescue RestClient::ExceptionWithResponse => e
            format.html { redirect_to(admin_services_path, notice: e.error) }
          end
        end
      end
    end

    def process_service_suspension
      respond_to do |format|
        case params['suspend']
        when 'true'
          begin
            @service.suspend!(no_credit: false)
            format.html { redirect_to(admin_service_path(@service), notice: 'Service successfully suspended!') }
          rescue RestClient::ExceptionWithResponse => e
            format.html { redirect_to(admin_service_path(@service), notice: e.error) }
          end
        when 'false'
          begin
            @service.unsuspend!
            format.html { redirect_to(admin_service_path(@service), notice: 'Service successfully unsuspended!') }
          rescue RestClient::ExceptionWithResponse => e
            format.html { redirect_to(admin_service_path(@service), notice: e.error) }
          rescue StandardError
            format.html { redirect_to(admin_service_path(@service), notice: 'Service cannot be unsuspended!') }
          end
        end
      end
    end

    def set_service
      @service = Service.unarchived.find(params[:id])
    end

    def services_params
      params.require(:service).permit(:name, :short_description, :user_id, :callback_url, :approval_description, :id)
    end

    private

    def search_params
      search_params_copy = params.dup
      search_params_copy.permit(:domain_name)
    end
  end
end
