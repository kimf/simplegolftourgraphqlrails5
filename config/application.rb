$: << File.expand_path("../lib", __dir__)
require File.expand_path("../boot", __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_view/railtie"
# require "action_cable/engine"

require "rails/test_unit/railtie"

require "graphql_reloader"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SimpleGolftour
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_record.schema_format = :sql

    config.middleware.use GraphQLReloader
    config.autoload_paths << Rails.root.join("app/graph")
    # config.autoload_paths << Rails.root.join("app/lib")
    config.autoload_paths << Rails.root.join("app/graph/mutations")
    config.autoload_paths << Rails.root.join("app/graph/types")
    config.active_record.raise_in_transactional_callbacks = true

    config.generators do |g|
      g.assets = false
      g.helper = false
      g.view_specs      false
      g.helper_specs    false
    end

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins "*"
        resource "*", headers: :any, methods: [:get, :post, :options]
      end
    end

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
