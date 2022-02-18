Recaptcha.configure do |config|
  config.site_key = EidManager::Application.config.customization.dig(:recaptcha, :site_key)
  config.secret_key = EidManager::Application.config.customization.dig(:recaptcha, :secret_key)
end
