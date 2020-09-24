# frozen_string_literal: true

class SubscriptionPaymentJob < ApplicationJob
  GRACE_PERIOD = 7.days
  SUBSCRIPTION_PERIOD = 1.month

  queue_as :default

  def perform(subscription)
    stripe_charge = create_charge(subscription)

    create_donation(subscription, stripe_charge) if stripe_charge
  end

  private

  def create_charge(subscription)
    customer = find_stripe_customer(subscription.user)
    plan = subscription.plan

    # if there's a plan use that amount
    # if not, use the subscription amount field
    amount = if plan
      plan.amount
    else
      subscription.amount
    end.to_i

    amount_in_cents = amount * 100

    client = Stripe::StripeClient.new
    charge, resp = client.request {
      Stripe::Charge.create(
        customer: customer,
        amount: amount_in_cents,
        description: "Debt Collective membership monthly payment",
        currency: "usd",
        metadata: {subscription_id: subscription.id, plan_id: plan&.id, amount: amount, user_id: subscription.user_id}
      )
    }

    charge
  rescue Stripe::CardError => e
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
    user = subscription.user

    donation = Donation.new(
      amount: stripe_charge.amount / 100,
      charge_data: JSON.parse(stripe_charge.to_json),
      customer_stripe_id: subscription.user.stripe_id,
      donation_type: Donation::DONATION_TYPES[:subscription],
      status: stripe_charge.status,
      user: user,
      user_data: {email: user.email, name: user.name}
    )

    subscription.update!(last_charge_at: DateTime.now, active: true) if donation.save!
  end
end
