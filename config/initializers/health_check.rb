# frozen_string_literal: true

HealthCheck.setup do |config|
  config.uri = 'health-check'
  config.success = 'success'
  config.http_status_for_error_text = 500
  config.http_status_for_error_object = 500

  # You can customize which checks happen on a standard health check, eg to set an explicit list use:
  config.standard_checks = %w[database migrations custom]

  # You can set what tests are run with the 'full' or 'all' parameter
  config.full_checks = %w[database migrations custom email cache redis resque-redis sidekiq-redis s3]

  # http status code used when the ip is not allowed for the request
  config.http_status_for_ip_whitelist_error = 403

  # Disable the error message to prevent /health_check from leaking
  # sensitive information
  config.include_error_in_response_body = false
end
