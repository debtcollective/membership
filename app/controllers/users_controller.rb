# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show]

  # GET /users/1
  # GET /users/1.json
  def show; end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
