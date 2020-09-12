# frozen_string_literal: true

class FindOverdueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    subscriptions_to_charge =
      Subscription.where(active: true).where(
        'last_charge_at <= ? OR last_charge_at = null',
        30.days.ago
      )

    subscriptions_to_charge.each do |subscription_to_charge|
      SubscriptionPaymentJob.perform_later(subscription_to_charge)
    end
  end
end
