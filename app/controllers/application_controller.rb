# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= SessionProvider.new(cookies).current_user
  rescue JWT::VerificationError => e
    # logout
    # alert sentry
    throw e
  end

  def logged_in?
    current_user != nil
  end
end
