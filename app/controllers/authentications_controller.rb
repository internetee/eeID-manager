class AuthenticationsController < ApplicationController
  include OrderableHelper
  before_action :authenticate_user!

  def index
    @authentications = current_user.authentications.order(created_at: :desc).all.page(params[:page])
  end
end
