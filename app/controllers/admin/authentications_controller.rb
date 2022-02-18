module Admin
class AuthenticationsController < BaseController
  include OrderableHelper

  def index
    @authentications = Authentication.order(created_at: :desc).all.page(params[:page])
  end

  def cors_preflight_check
    set_access_control_headers

    render plain: ''
  end

  private

  def search_params
    search_params_copy = params.dup
    search_params_copy.permit(:domain_name)
  end
end
end
