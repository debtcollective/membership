# frozen_string_literal: true

class StreaksController < ApplicationController
  before_action :set_user, only: %i[show]

  def show
    render json: { current_streak: "#{@user.current_streak} months" }
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
