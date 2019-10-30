# frozen_string_literal: true

class ToggleUserActiveSubscriptionPlanJob < ApplicationJob
  queue_as :default

  def perform(user_plan_change)
    # find the user
    user = User.find(user_plan_change.user_id)

    # disable current user subscription.
    old_subscription = user.active_subscription
    ActiveRecord::Base.transaction do
      old_subscription.update(active: false)

      # creates a new subscription with the new plan details.
      new_subscription = Subscription.new(
        user_id: user_plan_change.user_id,
        plan_id: user_plan_change.new_plan_id,
        last_charge_at: old_subscription.last_charge_at,
        active: true
      )

      if new_subscription.save
        UserPlanChange.find(user_plan_change.id).update(status: 'finished')
      end
    end
  end
end
