require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GovCraft
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'Asia/Seoul'
    config.i18n.available_locales = [:en, :ko]
    config.i18n.default_locale = :ko
    config.autoload_paths << Rails.root.join('lib')
    config.active_job.queue_adapter = ((!ENV['SIDEKIQ'] and (Rails.env.test? or Rails.env.development?)) ? :inline : :sidekiq)
    config.action_dispatch.default_headers = { 'X-Frame-Options' => 'ALLOWALL' }
  end
end
