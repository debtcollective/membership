# frozen_string_literal: true

class FindOverdueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    subscriptions_to_charge = Subscription.overdue

    subscriptions_to_charge.each do |subscription_to_charge|
      SubscriptionPaymentJob.perform_later(subscription_to_charge)
    end
  end
end
