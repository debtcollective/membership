# frozen_string_literal: true

class SubscriptionPaymentJob < ApplicationJob
  queue_as :default

  def perform(subscription)
    subscription.charge!
  end
end
