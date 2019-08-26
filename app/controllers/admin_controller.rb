# frozen_string_literal: true

class AdminController < ApplicationController
  layout 'admin'
  # before_action :require_admin

  # def require_admin
  #   redirect_to root_path unless current_user.admin?
  # end

  def current_page_title(page_title)
    @current_page_title ||= page_title
  end
end
