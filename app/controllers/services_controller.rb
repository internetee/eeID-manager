class ServicesController < ApplicationController
  include ServicesHelper
  include OrderableHelper
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:cors_preflight_check]
  before_action :set_service, only: %i[show edit update destroy]
  before_action :service_params, :set_default_email, only: %i[update]
  before_action :create_main_contact, only: %i[new]

  def index
    set_cors_header

    @services = current_user.services.unarchived.page(params[:page])
  end

  def show
    @service = current_user.services.unarchived.find(params[:id])
  end

  def new
    @service = current_user.services.new
  end

  def edit; end

  def create
    @service = current_user.services.new(service_params)
    set_default_email

    respond_to do |format|
      if @service.save
        format.html { redirect_to @service, notice: 'Service was successfully created.' }
        format.json { render :show, status: :created, location: @network }
      else
        format.html { render :new }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_old
    @service_params[:auth_methods] ||= []
    @service.disapprove! if attributes_changed? && @service.approved?

    update_emails

    respond_to do |format|
      if @service.update(@service_params)
        # @service.update_hydra_client
        format.html { redirect_to @service, notice: 'Service was successfully updated.' }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @service_params[:auth_methods] ||= []
    update_emails
    disapprove if attributes_changed? && @service.approved?
    @service.assign_attributes(@service_params)
    respond_to do |format|
      begin
        if @service.valid?
          @service.update_hydra_client
          @service.disapprove_hydra_client unless @service.approved?
          @service.save
          format.html { redirect_to @service, notice: 'Service was successfully updated.' }
          format.json { render :show, status: :ok, location: @service }
        else
          format.html { render :edit }
          format.json { render json: @service.errors, status: :unprocessable_entity }
        end
      rescue RestClient::ExceptionWithResponse => e
        format.html do
          flash.now[:notice] = e.error
          render :edit
        end
      end
    end
  end

  def disapprove
    @service_params[:client_id] = nil
    @service_params[:rejected] = false
    @service_params[:approved] = false
    @service_params[:suspended] = false
  end

  def destroy
    @service.archive!
    respond_to do |format|
      format.html { redirect_to services_url, notice: 'Service was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def service_params
    @service_params ||= params.require(:service).permit(:name, :short_description, :user_id,
                                                        :callback_url, :approval_description,
                                                        :id, :client_id, :contact_id,
                                                        :tech_email, :interrupt_email,
                                                        :environment, :approved, :suspended,
                                                        :rejected, :archived, auth_methods: [])
  end

  def cors_preflight_check
    set_access_control_headers

    render plain: ''
  end

  private

  def set_service
    @service = current_user.services.find(params[:id])
  end

  def search_params
    search_params_copy = params.dup
    search_params_copy.permit(:domain_name)
  end

  def set_cors_header
    response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
  end

  def set_access_control_headers
    response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
    response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, ' \
                                                       'Authorization, Token, Auth-Token, '\
                                                       'Email, X-User-Token, X-User-Email'
    response.headers['Access-Control-Max-Age'] = '3600'
  end

  def set_default_email
    @service.tech_email = @service.contact.email if @service.tech_email.blank?
    @service.interrupt_email = @service.contact.email if @service.interrupt_email.blank?
  end

  def update_emails
    if @service_params[:tech_email].blank?
      @service_params[:tech_email] = current_user.contacts.find_by(id: @service_params[:contact_id])&.email
    end
    return unless @service_params[:interrupt_email].blank?

    @service_params[:interrupt_email] = current_user.contacts.find_by(id: @service_params[:contact_id])&.email
  end

  def create_main_contact
    return if current_user.contacts.main.present?

    action = Actions::ContactCreate.new(current_user, main: true)
    action.call
  end

  def attributes_changed?
    tracking_attrs = %w[callback_url]
    tracking_attrs.each do |attr|
      return true if @service_params[attr] != @service.attributes[attr]
    end
    false
  end
end
