module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :validate_admin_role

    def validate_admin_role
      return if current_user.admin? # role?(User::ADMINISTATOR_ROLE)

      redirect_to(root_path)
    end
  end
end
