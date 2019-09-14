# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  def current_user
    return nil unless sso_cookie_present?

    payload, headers = sso_jwt_content

    # this means the validation failed
    # we logout the user since it has an invalid session
    if payload == false
      redirect_to logout_path
      return nil
    end

    return @current_user unless @current_user.nil?

    user, new_record = User.find_or_create_from_sso(payload)

    @current_user = CurrentUser.new(user, payload, new_record)
  end

  def logged_in?
    current_user != nil
  end

  private

  def sso_jwt_content
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
