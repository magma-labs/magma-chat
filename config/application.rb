require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MagmaChat
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # primary key type
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.active_job.queue_adapter = :sidekiq

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("lib")

    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/bot_tools)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/channels)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/constraints)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/controllers)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/controllers/concerns)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/helpers)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/jobs)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/mailers)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/models)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/models/concerns)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/reflexes)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/app/services)
    config.autoload_paths += %W(#{config.root}/lib/magma_chat/lib)

    config.action_dispatch.default_headers = {
      "Referrer-Policy" => "same-origin"
    }
  end
end
