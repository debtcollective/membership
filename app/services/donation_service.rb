# frozen_string_literal: tr

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
          source: params[:stripe_token]
        )

        # we are updating @user and giving to it stripe_id which is equal to
        # id of customer on Stripe
        user.update(stripe_id: customer.id)
      end

      # amount needs to be in cents
      amount = params[:amount]
      customer_ip = params[:customer_ip]

      # it's the stripe_token that we added in the hidden input
      card_token = params[:stripe_token]

      # checking if a card was given.
      if card_token.nil?
        Raven.capture_message("We couldn't process payment for user_id: #{user.id}", extra: {params: params})
        error = "We couldn't process your payment, please try again or contact us at admin@debtcollective.org for support"

        return nil, error
      end

      stripe_charge = Stripe::Charge.create(
        customer: user.stripe_id,
        amount: amount,
        description: "One time contribution of #{displayable_amount(amount)}",
        currency: "usd"
      )

      if stripe_charge
        donation = Donation.new(
          amount: amount,
          charge_data: JSON.parse(stripe_charge.to_json),
          charge_id: stripe_charge.id,
          charge_provider: "stripe",
          customer_ip: customer_ip,
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          status: stripe_charge.status,
          # TODO: add phone number and address
          user_data: {name: user.name, email: user.email},
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
        name: params[:name],
        email: params[:email],
        source: params[:stripe_token]
      )

      # amount is in cents
      amount = params[:amount]
      customer_ip = params[:customer_ip]

      stripe_charge = Stripe::Charge.create(
        customer: customer.id,
        amount: amount,
        description: "One time contribution of #{displayable_amount(amount)}",
        currency: "usd"
      )

      if stripe_charge
        donation = Donation.new(
          amount: amount,
          charge_data: JSON.parse(stripe_charge.to_json),
          charge_id: stripe_charge.id,
          charge_provider: "stripe",
          customer_ip: customer_ip,
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          status: stripe_charge.status,
          user_data: {name: params[:name], email: params[:email]}
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
