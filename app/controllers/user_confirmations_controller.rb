# frozen_string_literal: true

class UserConfirmationsController < ApplicationController
  layout "minimal"

  # GET /user_confirmations/confirm_email/:email_token
  def confirm_email_token
    @email_token = params[:email_token]
    @user = User.find_by_email_token!(@email_token)

    respond_to do |format|
      if @user
        format.html { render :confirm_email_token, status: :ok }
      else
        format.html { render :confirm_email_token, status: :not_found }
      end
    end
  end

  # POST /user_confirmations/confirm_email
  def confirm_email
    @email_token = user_confirmation_params[:email_token]
    @user = User.find_by_email_token!(@email_token)

    respond_to do |format|
      if @user&.activate!
        email_login_url = "#{ENV["DISCOURSE_URL"]}/session/email-login/#{@user.email_token}"

        format.html { redirect_to email_login_url }
        format.json { render json: {status: "success", message: "Email confirmed", redirect_url: email_login_url}, status: :ok }
      else
        Raven.capture_message(
          "Couldn't activate user with email_token",
          extra: {
            email_token: @email_token
          }
        )

        format.html { render plain: "We couldn't activate your account. If this is an error please contact support at https://debtcollective.org", status: :internal_server_error }
        format.json { render json: {status: "failed", message: "Invalid confirmation token"}, status: :not_found }
      end
    end
  end

  private

  def user_confirmation_params
    params.require(:user_confirmation).permit(:confirmation_token, :email_token)
  end
end
