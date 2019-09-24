# frozen_string_literal: true

class FindOverdueSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    subscriptions_to_charge = subscriptions_with_last_donation.select do |subscription|
      subscription[:last_donation] ? subscription[:last_donation].created_at <= 30.days.ago : true
    end

    subscriptions_to_charge.each do |subscription_to_charge|
      SubscriptionPaymentJob.perform_later(user: subscription_to_charge[:user], plan: subscription_to_charge[:plan])
    end
  end

  private

  def active_subscriptions
    Subscription.where(active: true)
  end

  def user_of(subscription)
    user ||= subscription.user
    user
  end

  def last_donation_for(user)
    user.donations
        .where(donation_type: Donation::DONATION_TYPES[:subscription])
        .order(created_at: :desc).first
  end

  def subscriptions_with_last_donation
    active_subscriptions.map do |active_subscription|
      {
        user: user_of(active_subscription),
        plan: active_subscription.plan,
        last_donation: last_donation_for(user_of(active_subscription))
      }
    end
  end
end
