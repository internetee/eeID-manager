module EisBilling
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    # skip_authorization_check # Temporary solution
    # skip_before_action :verify_authenticity_token # Temporary solution
    before_action :persistent
    before_action :authorized

    INITIATOR = 'billing'.freeze

    def auth_header
      # { Authorization: 'Bearer <token>' }
      request.headers['Authorization']
    end

    def decoded_token
      return unless auth_header

      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, billing_secret_key, true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end

    def accessable_service
      return decoded_token[0]['initiator'] == INITIATOR if decoded_token

      false
    end

    def logged_in?
      accessable_service
    end

    def authorized
      render json: { message: 'Access denied' }, status: :unauthorized unless logged_in?
    end

    def logger
      @logger ||= Rails.logger
    end

    def persistent
      return true if Feature.billing_system_integration_enabled?

      render json: { message: "We don't work yet!" }, status: :unauthorized
    end

    def billing_secret_key
      EidManager::Application.config.customization[:billing_system_integration]
                                    &.compact&.fetch(:billing_secret, '')
    end
  end
end
