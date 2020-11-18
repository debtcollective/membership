# frozen_string_literal: true

# Initializes sentry logging on rails
Raven.configure do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.current_environment = ENV["SENTRY_ENVIRONMENT"] || "development"
end
