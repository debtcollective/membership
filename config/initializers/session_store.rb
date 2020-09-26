Rails.application.config.session_store :cookie_store,
  key: "_membership_session",
  domain: ENV["COOKIE_DOMAIN"]
