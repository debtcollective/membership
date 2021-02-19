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
        # run the Discourse link account job to fetch and link with a Discourse account
        LinkDiscourseAccountJob.perform_later(@user)

        format.html { render :confirm, notice: "Email confirmed", status: :ok }
        format.json { render json: {status: "success", message: "Email confirmed"}, status: :ok }
      else
        format.html { render :confirm, notice: "Invalid confirmation token", status: :not_found }
        format.json { render json: {status: "failed", message: "Invalid confirmation token"}, status: :not_found }
      end
    end
  end

  # GET /user_confirmations/confirm_email/:email_token
  def confirm_email_token
    @user = User.find_by_email_token!(params[:email_token])

    respond_to do |format|
      if @user
        format.html { render :index, status: :ok }
      else
        format.html { render :index, status: :not_found }
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
