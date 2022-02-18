class AuthenticationsController < ApplicationController
  include OrderableHelper
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:cors_preflight_check]

  def index
    set_cors_header

    @authentications = current_user.authentications.order(created_at: :desc).all.page(params[:page])
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
end
