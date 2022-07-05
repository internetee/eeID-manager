# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'airbrake'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'devise'
gem 'jbuilder', '~> 2.11'
gem 'kaminari'
gem 'lhv', github: 'internetee/lhv', branch: 'master'
gem 'mimemagic', '~> 0.4.3'
gem 'money'

gem 'omniauth', '>=2.0.0'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-tara', github: 'internetee/omniauth-tara'
# gem 'omniauth-tara', path: 'vendor/gems/omniauth-tara'

gem 'pdfkit'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.6.0'
gem 'rails', '>= 6.0.3.1', '< 7.0'
gem 'rails-i18n'
gem 'recaptcha'
gem 'rest-client', '>= 2.0.1'
gem 'rubyzip', '>= 1.2.1'
gem 'scenic'
gem 'sprockets', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 6.0.0.rc.5'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'
end

group :development do
  gem 'brakeman', require: false
  gem 'listen', '>= 3.0.5', '< 3.8'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'simplecov', '~> 0.17.1', require: false
  gem 'webdrivers'
  gem 'webmock'
end

gem 'sidekiq', '~> 6.2'
