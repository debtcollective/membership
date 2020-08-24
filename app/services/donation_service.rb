# frozen_string_literal: tr

class DonationService
  class << self
    def save_donation_with_user(user, params)
      name = params[:name] || user.name
      email = params[:email] || user.email
      stripe_token = params[:stripe_token]

      # checking if a card was given.
      if stripe_token.nil?
        Raven.capture_message("We couldn't process payment for user_id: #{user.id}", extra: {params: params})
        error = "We couldn't process your payment, please try again or contact us at admin@debtcollective.org for support"

        return nil, error
      end

      customer = Stripe::Customer.create(
        name: name,
        email: email,
        source: stripe_token
      )

      user.update(stripe_id: customer.id)

      # amount needs to be in cents
      amount = params[:amount]
      customer_ip = params[:customer_ip]

      stripe_charge = Stripe::Charge.create(
        amount: amount,
        currency: "usd",
        customer: customer.id,
        description: "One time contribution of #{displayable_amount(amount)}"
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
      name = params[:name]
      email = params[:email]
      stripe_token = params[:stripe_token]

      customer = Stripe::Customer.create(
        name: name,
        email: email,
        source: stripe_token
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
          user_data: {
            name: name,
            email: email
          }
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
