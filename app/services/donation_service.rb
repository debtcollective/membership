# frozen_string_literal: true

class DonationService
  class << self
    def save_donation_with_user(user, params)
      if user.stripe_id.nil?
        # here we are creating a stripe customer with the help of the Stripe
        # library and pass as parameter email.
        # TODO: Add phone number and address
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

      stripe_charge = Stripe::Charge.create(
        customer: user.stripe_id,
        amount: amount,
        description: "One time donation of #{displayable_amount(amount)}",
        currency: "usd"
      )

      if stripe_charge
        donation = Donation.new(
          amount: amount / 100, # transformed from cents
          charge_data: stripe_charge.to_json,
          charge_id: stripe_charge.id,
          charge_provider: "stripe",
          customer_ip: customer_ip,
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          # TODO: add phone number and address
          user_data: {email: user.email, name: user.name},
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
      email = params[:stripeEmail]

      customer = Stripe::Customer.create(
        email: email,
        source: params[:stripeToken]
      )

      amount = params[:amount]
      customer_ip = params[:customer_ip]

      stripe_charge = Stripe::Charge.create(
        customer: customer.id,
        amount: amount,
        description: "One time donation of #{displayable_amount(amount)}",
        currency: "usd"
      )

      if stripe_charge
        donation = Donation.new(
          amount: amount / 100, # transformed from cents
          charge_data: stripe_charge.to_json,
          charge_id: stripe_charge.id,
          charge_provider: "stripe",
          customer_ip: customer_ip,
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          user_data: {email: email}
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
