# frozen_string_literal: true

class SessionsController < ApplicationController
  def login
    query_string = redirect_params.to_query
    url = "#{ENV['DISCOURSE_URL']}/session/sso_provider?#{query_string}"

    redirect_to url
  end

  def signup
    query_string = redirect_params.to_query
    url = "#{ENV['DISCOURSE_URL']}/session/sso_provider/signup?#{query_string}"

    redirect_to url
  end

  def redirect_params
    params.permit(:return_url).merge(return_url: root_url)
  end
end
