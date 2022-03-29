# frozen_string_literal: true

module Concerns
  module Service
    module HydraConnectable
      extend ActiveSupport::Concern
      API_CLIENT = Hydra::RestApi

      def bind_hydra_client
        if hydra_client_present?
          update_hydra_client
        else
          API_CLIENT.create_client(hydra_payload)
        end
      end

      def update_hydra_client
        API_CLIENT.update_client(regex_service_name, hydra_payload)
      end

      def delete_hydra_client
        API_CLIENT.delete_client(regex_service_name) if hydra_client_present?
      end

      def find_hydra_client
        API_CLIENT.get_client(regex_service_name)
      end

      def hydra_client_present?
        !find_hydra_client.nil?
      end

      def archive_hydra_client
        API_CLIENT.update_client_status(
          regex_service_name,
          'ARCHIVED'
        )
      end

      def suspend_hydra_client(no_credit)
        API_CLIENT.update_client_status(
          regex_service_name,
          no_credit ? 'SUSPENDED-NO-CREDIT' : 'SUSPENDED'
        )
      end

      def disapprove_hydra_client
        API_CLIENT.update_client_status(
          regex_service_name,
          'AWAITING_APPROVAL'
        )
      end

      def hydra_payload
        {
          client_id: regex_service_name,
          client_name: name,
          client_secret: password,
          redirect_uris: [callback_url],
          grant_types: [],
          response_types: ['code'],
          scope: "openid #{auth_methods * ' '}", # 'openid mid idcard smartid'
          logo_uri: '',
          contacts: [],
          client_secret_expires_at: 0,
          subject_type: 'public',
          token_endpoint_auth_method: 'client_secret_basic',
          userinfo_signed_response_alg: 'none',
          metadata: {
            display_user_consent: nil,
            oidc_client: {
              name: name,
              name_translations: {
                et: name,
                en: name,
                ru: name,
              },
              short_name: name,
              short_name_translations: {
                et: name,
                en: name,
                ru: name,
              },
              legacy_return_url: nil,
              institution: {
                registry_code: contact.identity_code,
                sector: 'public',
              },
              mid_settings: nil,
              smartid_settings: nil,
            },
          },
        }.to_json
      end
    end
  end
end
