# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def current_user
    return nil unless sso_cookie_present?

    payload = sso_payload

    # this means the validation failed
    # we logout the user since it has an invalid session
    if payload == false
      redirect_to logout_path
      return
    end

    @current_user ||= User.find_or_create_from_sso(sso_payload)
  end

  def authenticate_user!
    # this will check if a user exists or redirect to /login
    # following the same API as Devise
  end

  private

  def sso_payload
    token = cookies[ENV['SSO_COOKIE_NAME']]

    begin
      return JWT.decode(token, ENV['SSO_JWT_SECRET'], true, algorithm: 'HS256')
    rescue JWT::VerificationError
      # report to sentry
      return false
    end
  end

  def sso_cookie_present?
    cookies[ENV['SSO_COOKIE_NAME']].present?
  end
end
