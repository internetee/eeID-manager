require 'rest-client'
require 'json'
class RestClient::ExceptionWithResponse
  def error
    body = JSON.parse(@response.body)
    body['error_description'].empty? ? body['error'] : body['error_description']
  end
end

module Hydra
  class RestApi
    API_ENDPOINT = EidManager::Application.config.customization.dig(:tara, :ory_hydra_private)

    @headers = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
    }

    class << self
      def get_client(id)
        RestClient.get(
          "#{Hydra::RestApi::API_ENDPOINT}/clients/#{id}",
          headers: @headers
        ) do |response|
          return response.body if response.code == 200
        end
      end

      def create_client(payload)
        RestClient::Request.execute(
          method: :post,
          url: "#{Hydra::RestApi::API_ENDPOINT}/clients",
          payload: payload,
          headers: @headers
        )
      end

      def update_client(id, payload)
        RestClient::Request.execute(
          method: :put,
          url: "#{Hydra::RestApi::API_ENDPOINT}/clients/#{id}",
          payload: payload,
          headers: @headers
        )
      end

      def delete_client(id)
        RestClient.delete(
          "#{Hydra::RestApi::API_ENDPOINT}/clients/#{id}",
          headers: @headers
        )
      end

      def update_client_status(id, status)
        RestClient::Request.execute(
          method: :patch,
          url: "#{Hydra::RestApi::API_ENDPOINT}/clients/#{id}",
          payload: replace_status_json_patch(status),
          headers: @headers
        )
      end

      def replace_status_json_patch(status)
        '[
          {
            "op": "replace",
            "path": "/metadata",
            "value": {"status": "' + status + '"}
          }
        ]'
      end
    end
  end
end
