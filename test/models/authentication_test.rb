require 'test_helper'

class AuthenticationTest < ActiveSupport::TestCase
  setup do
    travel_to Time.parse('2010-07-05').in_time_zone
    Money.default_currency = 'EUR'
    @authentication = authentications(:one)
  end

  def test_run_process_on_log
    assert Authentication.process(tara2_smart_id_log)
    result = Authentication.last

    assert_equal result.principal_code, 'EE30303039914'
    assert_equal result.first_name, 'QUALIFIED OK1'
    assert_equal result.last_name, 'TESTNUMBER'
    assert_equal result.service, services(:one)
    assert_equal result.channel, 'SMART_ID'
    assert_equal result.created_at, Time.now
    assert_equal result.updated_at, Time.now
  end

  def test_auth_context_from_log_with_tara_mobile_id
    session_data = tara2_mobile_id_log['tara.session']
    result = Authentication.context_from_log(session_data['authenticationResult'])

    assert_equal result['channel'], 'MOBILE_ID'
    assert_equal result['last_name'], 'O’CONNEŽ-ŠUSLIK TESTNUMBER'
    assert_equal result['first_name'], 'MARY ÄNN'
    assert_equal result['principal_code'], 'EE60001019906'
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

  def tara2_mobile_id_log
    { "@timestamp"=>"2022-02-17T09:04:32.544Z",
      "@version"=>"1",
      "message"=>"Saving session with state: AUTHENTICATION_SUCCESS",
      "level"=>"INFO",
      "tara.session"=>{
        "sessionId"=>"9e2cbd71-06a8-4c5f-adbd-c74c01a8eb66",
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
          "idCode"=>"60001019906",
          "country"=>"EE", 
          "firstName"=>"MARY ÄNN",
          "lastName"=>"O’CONNEŽ-ŠUSLIK TESTNUMBER",
          "phoneNumber"=>'+37200000766',
          "subject"=>"EE60001019906",
          "dateOfBirth"=>[2000, 1, 1],
          "amr"=>"MOBILE_ID",
          "acr"=>"HIGH",
          "errorCode"=>nil,
          "midSessionId"=>"d959de58-6e60-4051-899f-764c6bd4f2e3"
        }
      }
    }
  end
  # rubocop:enable all
end
