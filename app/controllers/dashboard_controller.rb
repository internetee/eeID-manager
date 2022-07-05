class DashboardController < ApplicationController
  include OrderableHelper
  before_action :authenticate_user!
  before_action :redirect_admin

  def index
    @services = current_user.services.unarchived.order(created_at: :desc).page(params[:services_page]).per(10)
    @authentications = current_user.authentications.all.order(created_at: :desc).page(params[:authentications_page]).per(10)
  end

  def redirect_admin
    return unless current_user.admin?

    redirect_to admin_authentications_path
  end
end
