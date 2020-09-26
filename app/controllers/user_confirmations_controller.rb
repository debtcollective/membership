# frozen_string_literal: true

class UserConfirmationsController < ApplicationController
  layout "minimal"

  # GET /user_confirmations?confirmation_token=abcdef
  def index
    @confirmation_token = params[:confirmation_token]
    @user = User.find_by_confirmation_token(@confirmation_token)

    respond_to do |format|
      if @user
        format.html { render :index, status: :ok }
      else
        format.html { render :index, status: :not_found }
      end
    end
  end

  # POST /user_confirmations
  def create
    user = User.send_confirmation_instructions(email: current_user&.email || params[:email])

    respond_to do |format|
      if user.errors.empty?
        format.json { render json: {status: "success", message: "Confirmation email sent"}, status: :ok }
      else
        format.json { render json: {status: "failed", message: "Invalid confirmation token"}, status: :not_found }
      end
    end
  end

  # POST /user_confirmations/confirm
  def confirm
    @user = User.confirm_by_token(user_confirmation_params[:confirmation_token])
    @user_confirmed = @user.errors.empty?

    respond_to do |format|
      if @user_confirmed
        format.html { render :confirm, notice: "Email confirmed", status: :ok }
        format.json { render json: {status: "success", message: "Email confirmed"}, status: :ok }
      else
        format.html { render :confirm, notice: "Invalid confirmation token", status: :not_found }
        format.json { render json: {status: "failed", message: "Invalid confirmation token"}, status: :not_found }
      end
    end
  end

  private

  def user_confirmation_params
    params.require(:user_confirmation).permit(:confirmation_token)
  end
end
