# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, only: :destroy

  def create
    service_params =
      subscription_params.to_h.merge(
        {
          customer_ip: request.remote_ip
        }
      )

    # check if user is a bot using token recaptcha
    is_human = verify_recaptcha(action: "membership", minimum_score: 0.5, secret_key: ENV["RECAPTCHA_V3_SECRET_KEY"])

    # if users is a bot then return error
    unless is_human
      message = "Oops! Something went wrong. Please try again"
      error = "Human validation has failed"
      return render json: {status: "failed", errors: [error], message: message}, status: :unprocessable_entity
    end

    # TODO: remove this line once we deprecate the old behaviour with the member hub
    session.clear

    # We use current_user.user to make sure we are passing the user object and not the wrapper
    # TODO: find a better way to do this.
    subscription, errors = MembershipService.new(service_params, current_user&.user).execute

    respond_to do |format|
      if subscription.persisted?
        user = subscription.user

        message = I18n.t(
          "subscription.alerts.success"
        )

        format.html do
          flash[:success] = message
          redirect_to root_path
        end
        format.json { render json: {status: "succeeded", message: message}, status: :ok }
      else
        message = "Oops! Something went wrong. Please try again"

        if errors["base"].any?
          message = errors["base"].first
        end

        format.html do
          flash[:error] = message
          render :new
        end
        format.json { render json: {status: "failed", errors: errors.messages, message: message}, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user/:user_id/subscription
  # DELETE /user/:user_id/subscription.json
  def destroy
    subscription = current_user.active_subscription

    if subscription&.cancel!
      head :ok
    else
      head :bad_request
    end
  end

  def subscription_params
    params.require(:subscription).permit(
      :address_city,
      :address_country_code,
      :address_line1,
      :address_zip,
      :amount,
      :chapter,
      :email,
      :name,
      :phone_number,
      :stripe_token
    )
  end
end
