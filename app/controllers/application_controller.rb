class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale
  content_security_policy do |policy|
    policy.style_src :self, 'www.gstatic.com', :unsafe_inline
  end

  rescue_from SocketError do |e|
    respond_to do |format|
      format.html do
        flash[:notice] = e.message
        redirect_to root_path
      end
    end
  end

  def set_locale
    I18n.locale = current_user&.locale || cookies[:locale] || I18n.default_locale
  end

  # If needed, add updated_by to the params hash. Updated by takes format of "123 - User Surname"
  # When no current user is set, return back the hash as is.
  def merge_updated_by(update_params)
    return update_params unless current_user

    user_string = "#{current_user.id} - #{current_user.display_name}"
    update_params.merge(updated_by: user_string)
  end
end
