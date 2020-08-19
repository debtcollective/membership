# frozen_string_literal: true

class DonationService
  class << self
    def save_donation_with_user(user, params)
      if user.stripe_id.nil?
        # here we are creating a stripe customer with the help of the Stripe
        # library and pass as parameter email.
        # TODO: Add phone number
        customer = Stripe::Customer.create(
          name: user.name,
          email: user.email,
          source: params[:stripeToken]
        )

        # we are updating @user and giving to it stripe_id which is equal to
        # id of customer on Stripe
        user.update(stripe_id: customer.id)
      end

      amount = params[:amount]
      customer_ip = params[:customer_ip]

      # it's the stripeToken that we added in the hidden input
      card_token = params[:stripeToken]

      # checking if a card was given.
      if card_token.nil?
        Raven.capture_message("We couldn't process payment for user_id: #{user.id}", extra: {params: params})
        error = "We couldn't process your payment, please try again or contact us at admin@debtcollective.org for support"

        return nil, error
      end

      charge = Stripe::Charge.create(
        customer: user.stripe_id,
        amount: amount,
        description: "One time donation of #{displayable_amount(amount)}",
        currency: "usd"
      )

      if charge
        donation = Donation.new(
          amount: amount / 100, # transformed from cents
          charge_id: charge.id,
          charge_provider: "stripe",
          customer_ip: customer_ip,
          customer_stripe_id: user.stripe_id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          user_id: user.id
        )

        donation.save
        return donation, nil
      end

      false
    rescue Stripe::StripeError => e
      Raven.capture_exception(e)

      [nil, e.message]
    end

    def save_donation_without_user(params)
      customer = Stripe::Customer.create(
        email: params[:stripeEmail],
        source: params[:stripeToken]
      )

      amount = params[:amount]
      customer_ip = params[:customer_ip]

      charge = Stripe::Charge.create(
        customer: customer.id,
        amount: amount,
        description: "One time donation of #{displayable_amount(amount)}",
        currency: "usd"
      )

      if charge
        donation = Donation.new(
          amount: amount / 100, # transformed from cents
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          customer_ip: customer_ip
        )

        donation.save

        return donation
      end

      [false, nil]
    rescue Stripe::StripeError => e
      Raven.capture_exception(e)

      [nil, e.message]
    end

    def displayable_amount(amount)
      return "$0" unless amount

      ActionController::Base.helpers.number_to_currency(amount.to_f / 100)
    end
  end
end
