OpenIDConnect.logger = Rails.logger
OpenIDConnect.debug!

OpenIDConnect.http_config do |config|
  config.proxy = EidManager::Application.config.customization.dig(:tara, :proxy)
end

OmniAuth.config.logger = Rails.logger
# Block GET requests to avoid exposing self to CVE-2015-9284
OmniAuth.config.allowed_request_methods = [:post]

signing_keys = EidManager::Application.config.customization.dig(:tara, :keys).to_json
issuer = EidManager::Application.config.customization.dig(:tara, :issuer)
host = EidManager::Application.config.customization.dig(:tara, :host)
port = EidManager::Application.config.customization.dig(:tara, :port)
authorization_endpoint = EidManager::Application.config.customization.dig(:tara, :authorization_endpoint)
token_endpoint = EidManager::Application.config.customization.dig(:tara, :token_endpoint)
jwks_uri = EidManager::Application.config.customization.dig(:tara, :jwks_uri)
identifier = EidManager::Application.config.customization.dig(:tara, :identifier)
secret = EidManager::Application.config.customization.dig(:tara, :secret)
redirect_uri = EidManager::Application.config.customization.dig(:tara, :redirect_uri)
scheme = EidManager::Application.config.customization.dig(:tara, :scheme)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider 'tara', {
    name: 'tara',
    scope: %w[openid idcard mid smartid],
    state: SecureRandom.hex(10),
    client_signing_alg: :RS256,
    client_jwk_signing_key: signing_keys,
    send_scope_to_token_endpoint: false,
    send_nonce: true,
    issuer: issuer,

    client_options: {
      scheme: scheme,
      host: host,
      port: port,
      authorization_endpoint: authorization_endpoint,
      token_endpoint: token_endpoint,
      userinfo_endpoint: nil, # Not implemented
      jwks_uri: jwks_uri,
      identifier: identifier,
      secret: secret,
      redirect_uri: redirect_uri,
    },
  }
end
