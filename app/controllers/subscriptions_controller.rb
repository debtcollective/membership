# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

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
end
