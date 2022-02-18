require 'test_helper'

class NotifyIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  setup do
    @user = users(:customer)
    sign_in @user
    Money.default_currency = 'EUR'
  end

  def test_create_notify
    assert_difference -> { Authentication.count } do
      post api_v1_notify_url, params: tara2_smart_id_log
    end
  end

  private

  # rubocop:disable all
  def tara2_smart_id_log
    { "@timestamp"=>"2022-02-17T09:04:32.544Z",
      "@version"=>"1",
      "message"=>"Saving session with state: AUTHENTICATION_SUCCESS",
      "level"=>"INFO",
      "tara.session"=>{
        "sessionId"=>"e15de115-bdaa-4c93-aa49-d8acd7ea31b9",
        "state"=>"AUTHENTICATION_SUCCESS",
        "loginRequestInfo"=>{
          "loginChallengeExpired"=>true,
          "userCancelUri"=>"https://eid.test/auth/tara/callback?error=",
          "clientId"=>"oidc-e4d47e48-8c8c-48ff-a628-d18edfe9b506-1",
          "institution"=>{
            "registry_code"=>"38201190236",
            "sector"=>"public"
          },
          "redirectUri"=>"https://eid.test/auth/tara/callback",
          "oidcState"=>"ffaa5ce6e820bd8411463394fdedd796",
          "challenge"=>"3eeb5b97cd074b5dab6ee48c1445f8e0",
          "client"=>{
            "client_id"=>"oidc-e4d47e48-8c8c-48ff-a628-d18edfe9b506-1",
            "scope"=>"openid idcard mid smartid" 
          }, 
          "requested_scope"=>["openid", "idcard", "mid", "smartid"],
          "request_url"=>"http://127.0.0.1:4444/oauth2/auth?client_id="
        }, 
        "allowedAuthMethods"=>["ID_CARD", "MOBILE_ID", "SMART_ID"],
        "authenticationResult"=>{
          "email"=>nil,
          "idCode"=>"30303039914",
          "country"=>"EE", 
          "firstName"=>"QUALIFIED OK1",
          "lastName"=>"TESTNUMBER",
          "phoneNumber"=>nil,
          "subject"=>"EE30303039914",
          "dateOfBirth"=>[1903, 3, 3],
          "amr"=>"SMART_ID",
          "acr"=>"HIGH",
          "errorCode"=>nil,
          "sidSessionId"=>"84beb112-8f40-428d-bed7-6998fa67bbe5"
        }
      }
    }
  end
end