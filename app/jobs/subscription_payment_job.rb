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

  private

  def create_charge(subscription)
    customer = find_stripe_customer(subscription.user)
    plan = subscription.plan

    client = Stripe::StripeClient.new
    plan_amount_in_cents = (plan.amount * 100).to_i
    charge, resp = client.request {
      Stripe::Charge.create(
        customer: customer,
        amount: plan_amount_in_cents,
        description: "Charged #{DonationService.displayable_amount(plan_amount_in_cents)} for #{plan.name}",
        currency: "usd",
        metadata: {"plan_id" => plan.id, "user_id" => subscription.user.id}
      )
    }

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
    donation = Donation.new(
      amount: subscription.plan.amount,
      charge_data: JSON.parse(stripe_charge.to_json),
      customer_stripe_id: subscription.user.stripe_id,
      donation_type: Donation::DONATION_TYPES[:subscription],
      status: stripe_charge.status,
      user_id: subscription.user.id,
      user_data: {emai: user.email, name: user.name}
    )
    subscription.update!(last_charge_at: DateTime.now, active: true) if donation.save!
  end
end
