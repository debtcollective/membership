# frozen_string_literal: true

class SubscriptionPaymentJob < ApplicationJob
  GRACE_PERIOD = 7.days
  SUBSCRIPTION_PERIOD = 1.month

  queue_as :default

  def perform(subscription)
    plan = subscription.plan

    create_charge(subscription)
    create_donation(subscription, plan.amount)
  end

  def displayable_amount(amount)
    return '$0' unless amount

    ActionController::Base.helpers.number_to_currency(amount.to_f / 100)
  end

  def create_charge(subscription)
    customer = Stripe::Customer.retrieve(subscription.user.stripe_id)
    plan = subscription.plan

    Stripe::Charge.create(
      customer: customer,
      amount: (plan.amount * 100).to_i, # amount in cents
      description: "Charged #{displayable_amount(plan.amount)} for #{plan.name}",
      currency: 'usd'
    )
  rescue Stripe::CardError
    # TODO: Add Sentry log error here.
    disable_subscription(subscription)
  end

  def disable_subscription(subscription)
    if subscription.last_charge
      beyond_grace_period = subscription.last_charge >= (SUBSCRIPTION_PERIOD.ago + GRACE_PERIOD.ago)
      subscription.update(active: false) if beyond_grace_period
    else
      subscription.update(active: false)
    end
  end

  def create_donation(subscription, amount)
    new_charge = Donation.new(
      amount: amount / 100, # transformed from cents
      customer_stripe_id: subscription.user.stripe_id,
      donation_type: Donation::DONATION_TYPES[:subscription]
    )
    subscription.update(last_charge: DateTime.now, active: true) if new_charge.save!
  end
end
