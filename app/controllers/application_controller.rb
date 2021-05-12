# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  before_action :set_raven_context
  helper_method :current_user, :logged_in?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  add_flash_types :success, :warning, :error, :info

  def current_user
    @current_user ||= SessionProvider.new(cookies, session).current_user
  rescue JWT::VerificationError => e
    # TODO: logout user with invalid session
    Raven.capture_exception(e)
    raise ActionController::Forbidden
  end

  def logged_in?
    !!current_user
  end

  def authenticate_user!
    unless logged_in?
      if request.format.json?
        head :unauthorized
      else
        redirect_to_home_page
      end
    end
  end

  def redirect_to_home_page
    redirect_to ENV["HOME_PAGE_URL"]
  end

  def not_found
    raise ActionController::RoutingError.new("Not Found")
  end

  private

  def set_raven_context
    Raven.user_context(
      id: current_user&.id,
      email: current_user&.email,
      external_id: current_user&.external_id
    )
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
