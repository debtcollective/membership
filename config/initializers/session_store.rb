domain = Rails.env.test? ? "127.0.0.1" : ENV["COOKIE_DOMAIN"]

Rails.application.config.session_store :cookie_store,
  key: "_membership_session",
  domain: domain
