# frozen_string_literal: true

class SessionProvider
  attr_accessor :cookies, :session

  def initialize(cookies, session)
    @cookies = cookies
    @session = session
  end

  def current_user
    session_user_id = session[:user_id]

    if sso_cookie_present?
      payload, headers = sso_jwt_content

      user, new_record = User.find_or_create_from_sso(payload)

      current_user = CurrentUser.new(user, payload, new_record)
    elsif session_user_id
      user = User.find(session_user_id)
      new_record = user.new_record?
      payload = {}

      current_user = CurrentUser.new(user, payload, new_record)
    end

    # clean up membership session if there's a Discourse session available
    session.clear if sso_cookie_present? && session_user_id

    current_user
  end

  private

  def sso_jwt_content
    token = cookies[ENV["SSO_COOKIE_NAME"]]

    # this may throw JWT::VerificationError
    # let those calling current_user handle the error
    JWT.decode(token, ENV["SSO_JWT_SECRET"], true, algorithm: "HS256")
  end

  def sso_cookie_present?
    cookies[ENV["SSO_COOKIE_NAME"]].present?
  end
end
