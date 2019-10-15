# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :set_user, only: %i[destroy]

  # DELETE /user/:user_id/subscription
  # DELETE /user/:user_id/subscription.json
  def destroy
    head :not_authorized unless current_user == @user

    subscription = @user.active_subscription

    subscription.active = false
    if subscription.save
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
