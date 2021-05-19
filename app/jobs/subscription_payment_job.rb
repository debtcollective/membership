# frozen_string_literal: true

class SubscriptionNotOverdueError < StandardError
  def initialize(subscription, msg = "The subscription you are trying to charge is not overdue")
    @subscription = subscription
    super(msg)
  end

  def raven_context
    {subscription_id: subscription.id}
  end
end

class SubscriptionPaymentJob < ApplicationJob
  queue_as :default

  def perform(subscription)
    raise SubscriptionNotOverdueError.new(subscription) unless subscription.overdue?

    stripe_charge = create_charge(subscription)

    create_donation(subscription, stripe_charge) if stripe_charge
  end

  private

  def create_charge(subscription)
    user = subscription.user
    customer = user.find_stripe_customer

    # this shouldn't happen, but we need to handle this case
    unless customer
      Raven.capture_message(
        "User with subscription doesn't have a valid Stripe Customer",
        extra: {
          user_id: user.id,
          email: user.email,
          subscription_id: subscription.id,
          customer_id: customer&.id
        }
      )

      disable_subscription(subscription)

      return
    end

    amount = subscription.amount.to_i
    amount_in_cents = amount * 100

    client = Stripe::StripeClient.new
    charge, _ = client.request {
      Stripe::Charge.create(
        customer: customer,
        amount: amount_in_cents,
        description: "Debt Collective membership monthly payment",
        currency: "usd",
        metadata: {subscription_id: subscription.id, user_id: user.id}
      )
    }

    # If charge was made correctly, return it
    if charge.paid?
      # reset subscription failed_charge_count
      subscription.failed_charge_count = 0
      subscription.save

      charge
    else
      subscription.failed_charge_count = subscription.failed_charge_count + 1
      subscription.save

      disable_subscription(subscription)

      false
    end
  rescue Stripe::CardError => e
    Raven.capture_exception(e)
    disable_subscription(subscription)

    false
  end

  def disable_subscription(subscription)
    if subscription.beyond_grace_period?
      subscription.disable!
    end
  end

  def create_donation(subscription, stripe_charge)
    user = subscription.user

    donation = subscription.donations.new(
      amount: stripe_charge.amount / 100,
      charge_data: JSON.parse(stripe_charge.to_json),
      customer_stripe_id: user.stripe_id,
      donation_type: Donation::DONATION_TYPES[:subscription],
      status: stripe_charge.status,
      user: user,
      user_data: {email: user.email, name: user.name}
    )

    donation.save!
    subscription.update!(last_charge_at: DateTime.now, status: :active)
  end
end
