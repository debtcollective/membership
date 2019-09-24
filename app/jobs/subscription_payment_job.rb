# frozen_string_literal: true

class SubscriptionPaymentJob < ApplicationJob
  queue_as :default

  def perform(subscription)
    user = subscription[:user]
    plan = subscription[:plan]

    create_charge(user, plan)

    create_donation(user, plan.amount)
  end

  protected

  def displayable_amount(amount)
    return '$0' unless amount

    ActionController::Base.helpers.number_to_currency(amount.to_f / 100)
  end

  private

  def create_charge(user, plan)
    customer = Stripe::Customer.retrieve(user.stripe_id)
    Stripe::Charge.create(
      customer: customer,
      amount: (plan.amount * 100).to_i, # amount in cents
      description: "Charged #{displayable_amount(plan.amount)} for #{plan.name}",
      currency: 'usd'
    )
  rescue Stripe::CardError => e
    # TODO: Add Sentry log error here.
  end

  def create_donation(user, amount)
    new_charge = Donation.new(
      amount: amount / 100, # transformed from cents
      customer_stripe_id: user.stripe_id,
      donation_type: Donation::DONATION_TYPES[:subscription]
    )
    new_charge.save!
  end
end
