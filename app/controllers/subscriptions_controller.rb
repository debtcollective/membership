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

    # We use current_user.user to make sure we are passing the user object and not the wrapper
    # TODO: find a better way to do this.
    subscription, errors = MembershipService.new(service_params, current_user&.user).execute

    respond_to do |format|
      if subscription.persisted?
        user = subscription.user

        # send welcome email
        UserMailer.welcome_email(user: user).deliver_later

        # create temporary session
        session[:user_id] = user.id

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
