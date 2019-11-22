# frozen_string_literal: true

class UsersController < ApplicationController
  layout 'backoffice'
  before_action :set_user
  before_action :verify_current_user

  # GET /users/1
  # GET /users/1.json
  def show
    current_page_title('Your dashboard')
  end

  # pages
  def subscription
    current_page_title('Subscription management')
    @is_subscription_changing = UserPlanChange.where(user_id: @user.id, status: 'pending').first
  end

  def donation_history
    current_page_title('Donation history')
  end

  private

  def current_page_title(page_title)
    @current_page_title ||= page_title
  end

  def verify_current_user
    redirect_to root_path unless current_user == @user
  end

  def set_user
    user_param_id = params[:id] || params[:user_id]
    @user = User.find(user_param_id)
  end
end
