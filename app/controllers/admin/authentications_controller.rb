module Admin
  class AuthenticationsController < BaseController
    include OrderableHelper
    def index
      @authentications = Authentication.order(created_at: :desc).all.page(params[:page])
    end
  end
end
