# frozen_string_literal: true

class UserConfirmationsController < ApplicationController
  layout "minimal"
  before_action :authenticate_user!, only: :create

  # GET /users/confirmation?confirmation_token=abcdef
  def show
    @confirmation_token = params[:confirmation_token]
    @user = User.find_by_confirmation_token(@confirmation_token)

    respond_to do |format|
      format.html { render :show }
    end
  end

  # POST /users/confirmation
  def create
    user = User.send_confirmation_instructions(email: current_user.email || params[:email])

    if user.errors.empty?
      format.json { render json: {status: "success", message: "Confirmation email sent"}, status: :ok }
    else
      format.json { render json: {status: "failed", message: "Invalid confirmation token"}, status: :not_found }
    end
  end

  # POST /users/confirmation/confirm
  def confirm
    @user = User.confirm_by_token(user_confirmation_params[:confirmation_token])
    @user_confirmed = @user.errors.empty?

    if @user_confirmed
      format.html { render :confirm, notice: "Email confirmed" }
      format.json { render json: {status: "success", message: "Email confirmed"}, status: :ok }
    else
      format.html { render :confirm, notice: "Invalid confirmation token" }
      format.json { render json: {status: "failed", message: "Invalid confirmation token"}, status: :not_found }
    end
  end

  def user_confirmation_params
    params.require(:user_confirmation).permit(:confirmation_token)
  end
end
