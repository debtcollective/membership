# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show]

  # GET /users/1
  # GET /users/1.json
  def show
    redirect_to root_path unless current_user == @user
    @is_subscription_changing = UserPlanChange.where(user_id: @user.id, status: 'pending').first
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
