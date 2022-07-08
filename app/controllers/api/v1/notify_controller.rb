require 'jwt'
module Api
  module V1
    class NotifyController < ActionController::API
      before_action :require_jwt

      # POST api/v1/notify
      def create
        Authentication.process(params)

        head(:created)
      end

      def require_jwt
        token = request.headers['HTTP_AUTHORIZATION']
        return if token && valid_token(token)

        head :forbidden
      end

      private

      def jwt_secret
        Rails.configuration.customization['jwt_secret']
      end

      def issuer
        Rails.configuration.customization['issuer']
      end

      def build_jwt
        payload = { iss: issuer,
                    name: 'bridge',
                    roles: ['bridge'] }

        JWT.encode payload, jwt_secret, 'HS256'
      end

      def valid_token(token)
        return false unless token

        begin
          JWT.decode token.gsub('Bearer ', ''), jwt_secret, true, verify_iss: true,
                                                                  iss: issuer,
                                                                  algorithm: 'HS256'
          return true
        rescue JWT::DecodeError => e
          Rails.logger.warn "Error decoding the JWT: #{e}"
        end
        false
      end
    end
  end
end
