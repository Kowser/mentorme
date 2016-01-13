require File.expand_path('../boot', __FILE__)
require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Mentorme
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true
    config.login_regexp = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z|\A[\(]?[2-9]{1}[\d]{2}[\)]?[-. ]?([\d]{3})[-. ]?([\d]{4})\z/

    # Devise layouts
    config.to_prepare do
        Devise::SessionsController.layout "landing"
        Devise::SessionsController.skip_before_action :load_organization, only: [:destroy]
        Devise::RegistrationsController.layout "landing", :only => [:new, :create]
        Devise::ConfirmationsController.layout "landing"
        Devise::PasswordsController.layout "landing"
    end

    config.event_tracker.mixpanel_key = ENV['MIXPANEL_TOKEN']
  end
end
