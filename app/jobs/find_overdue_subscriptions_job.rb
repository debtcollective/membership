# frozen_string_literal: true

class FindOverdueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    subscriptions_to_charge = Subscription.active.select do |subscription|
      # create charge if there's no last_charge_at date, meaning it would be the
      # first time we attempt to charge this customer this subscription.
      subscription.last_charge_at ? subscription.last_charge_at <= 30.days.ago : true
    end

    subscriptions_to_charge.each do |subscription_to_charge|
      SubscriptionPaymentJob.perform_later(subscription_to_charge)
    end
  end
end
