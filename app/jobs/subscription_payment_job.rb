# frozen_string_literal: true

class SubscriptionPaymentJob < ApplicationJob
  GRACE_PERIOD = 7.days
  SUBSCRIPTION_PERIOD = 1.month

  queue_as :default

  def perform(subscription)
    plan = subscription.plan

    stripe_charge = create_charge(subscription)

    create_donation(subscription, stripe_charge) if stripe_charge
  end

  protected

  def displayable_amount(amount)
    return '$0' unless amount

    ActionController::Base.helpers.number_to_currency(amount.to_f / 100)
  end

  private

  def create_charge(subscription)
    customer = find_stripe_customer(subscription.user)
    plan = subscription.plan

    client = Stripe::StripeClient.new
    charge, resp = client.request do
      Stripe::Charge.create(
        customer: customer,
        amount: (plan.amount * 100).to_i, # amount in cents
        description: "Charged #{displayable_amount(plan.amount)} for #{plan.name}",
        currency: 'usd',
        metadata: { 'plan_id' => plan.id, 'user_id' => subscription.user.id }
      )
    end

    resp
  rescue Stripe::CardError
    # TODO: Add Sentry log error here.
    disable_subscription(subscription)
  end

  def find_stripe_customer(user)
    customer = Stripe::Customer.retrieve(user.stripe_id) if user.stripe_id

    unless customer
      customer = Stripe::Customer.create(email: user.email)
      user.update(stripe_id: customer.id)
    end
    customer
  end

  def disable_subscription(subscription)
    if subscription.last_charge_at
      beyond_grace_period = subscription.last_charge_at >= (SUBSCRIPTION_PERIOD.ago + GRACE_PERIOD.ago)
      subscription.update(active: false) if beyond_grace_period
    else
      subscription.update(active: false)
    end
  end

  def create_donation(subscription, stripe_charge)
    new_charge = Donation.new(
      amount: subscription.plan.amount,
      customer_stripe_id: subscription.user.stripe_id,
      donation_type: Donation::DONATION_TYPES[:subscription],
      user_id: subscription.user.id,
      status: 'pending',
      user_data: stripe_charge.to_json
    )
    subscription.update!(last_charge_at: DateTime.now, active: true) if new_charge.save!
  end
end
