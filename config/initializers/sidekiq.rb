# frozen_string_literal: true

redis_namespace = "sidekiq_#{Rails.application.class.module_parent_name}_#{Rails.env}".downcase

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    namespace: redis_namespace
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    namespace: redis_namespace
  }
end
