# frozen_string_literal: true

class StreaksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show]

  def show
    render json: { current_streak: @user.current_streak ? "#{@user.current_streak} months" : "You don't have an active membership" }
  end

  private

  def set_user
    @user = current_user
  end
end
