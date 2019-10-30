# frozen_string_literal: true

class ChangeSubscriptionPlansJob < ApplicationJob
  queue_as :default

  def perform
    pending_user_plan_changes = UserPlanChange.where(status: 'pending')
    pending_user_plan_changes.each do |pending_user_plan_change|
      ToggleUserActiveSubscriptionPlanJob.perform_later(pending_user_plan_change)
    end
  end
end
