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

    subscription, errors = MembershipService.new(service_params, current_user).execute

    respond_to do |format|
      if subscription.persisted?
        # send welcome email
        UserMailer.welcome_email(user: subscription.user).deliver_later

        message = I18n.t(
          "subscription.alerts.success"
        )

        format.html do
          flash[:success] = message
          redirect_to root_path
        end
        format.json { render json: {status: "succeeded", message: message}, status: :ok }
      else
        format.html do
          error = "Oops! Something went wrong. Please try again"

          if errors["base"].any?
            error = errors["base"].first
          end

          flash[:error] = error
          render :new
        end
        format.json { render json: {status: "failed", errors: errors.messages}, status: :unprocessable_entity }
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
      :email,
      :name,
      :phone_number,
      :stripe_token
    )
  end
end
