# frozen_string_literal: true

class FindOverdueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    subscriptions_to_charge = active_subscriptions.select do |subscription|
      # create charge if there's no last_charge date, meaning it would be the
      # first time we attempt to charge this customer this subscription.
      subscription.last_charge ? subscription.last_charge <= 30.days.ago : true
    end

    subscriptions_to_charge.each do |subscription_to_charge|
      SubscriptionPaymentJob.perform_later(subscription_to_charge)
    end
  end

  private

  def active_subscriptions
    Subscription.where(active: true)
  end
end
