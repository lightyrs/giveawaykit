require File.expand_path('../boot', __FILE__)

require 'rails/all'

PORT = ENV['PORT']
RACK_ENV = ENV['RACK_ENV']

FB_NAMESPACE = ENV['FB_NAMESPACE']
FB_APP_ID = ENV['FB_APP_ID']
FB_OAUTH_KEY = ENV['FB_OAUTH_KEY']
FB_APP_SECRET = ENV['FB_APP_SECRET']

MANDRILL_KEY = ENV['MANDRILL_KEY']
MANDRILL_USERNAME = ENV['MANDRILL_USERNAME']

STRIPE_SECRET_KEY = ENV['STRIPE_SECRET_KEY']
STRIPE_PUBLISHABLE_KEY = ENV['STRIPE_PUBLISHABLE_KEY']

S3_ACCESS_KEY = ENV['S3_ACCESS_KEY']
S3_SECRET = ENV['S3_SECRET']

BITLY_USERNAME = ENV['BITLY_USERNAME']
BITLY_KEY = ENV['BITLY_KEY']

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Giveawaykit
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.config.enforce_available_locales = false

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0.1'
  end
end
