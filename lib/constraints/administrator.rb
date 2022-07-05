module Constraints
  class Administrator
    def initialize; end

    def matches?(request)
      user = request.env['warden']&.user(:user)
      return false unless user

      user.admin?
    end
  end
end
