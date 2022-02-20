require 'test_helper'
require 'support/semantic_ui_helper'
require 'selenium/webdriver'
require 'webmock/minitest'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include Devise::Test::IntegrationHelpers

  include SemanticUiHelper

  # setup do
  #   WebMock.disable_net_connect!(allow_localhost: true)
  #   stub_request(:get, /chromedriver/)
  #     .to_return(status: 200, body: '', headers: {})
  # end

  teardown do
    WebMock.reset!
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  Capybara.register_driver(:headless_chrome) do |app|
    options = ::Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--window-size=1400,1400')
    options.add_argument('--disable-dev-shm-usage')

    caps = [
      options,
      Selenium::WebDriver::Remote::Capabilities.chrome,
    ]

    Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: caps)
  end

  driven_by :headless_chrome
  Capybara.server = :puma, { Silent: true }

  def stub_hydra_requests_ok
    stub_request(:any, "#{API_ENDPOINT}/clients/#{@service_one.regex_service_name}")
      .to_return(status: 200)
  end

  def stub_hydra_client_does_not_exist
    stub_request(:get, "#{API_ENDPOINT}/clients/#{@service_one.regex_service_name}")
      .to_return(status: 401)
  end

  def stub_post_hydra_client_ok
    stub_request(:post, "#{API_ENDPOINT}/clients")
      .to_return(status: 200)
  end
end
