if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.command_name 'test'
  SimpleCov.start 'rails'
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/mock'
require 'capybara/rails'
require 'capybara/minitest'
require 'webmock/minitest'
require 'support/message_delivery'
require 'spy/integration'

class ActiveSupport::TestCase
  WebMock.disable_net_connect!(allow_localhost: true, allow: 'chromedriver.storage.googleapis.com')
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  API_ENDPOINT = EidManager::Application.config.customization.dig(:tara, :ory_hydra_private)
  # Add more helper methods to be used by all tests here...
  def clear_email_deliveries
    ActionMailer::Base.deliveries.clear
  end
end
