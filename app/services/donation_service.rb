# frozen_string_literal: tr

class DonationService
  class << self
    def save_donation_with_user(user, params)
      name = params[:name] || user.name
      email = params[:email] || user.email
      phone_number = params[:phone_number].to_s
      stripe_token = params[:stripe_token]
      valid_email = ValidEmail2::Address.new(email).valid?

      if name.blank? || !valid_email || phone_number.blank?
        return [nil, "Please make sure all fields are valid"]
      end

      # checking if a card was given.
      if stripe_token.blank?
        Raven.capture_message("We couldn't process payment for user_id: #{user.id}", extra: {params: params})
        error = "We couldn't process your payment, please try again or contact us at admin@debtcollective.org for support"

        return nil, error
      end

      # Stripe max length for the phone field is 20
      stripe_phone_number = phone_number.truncate(20, omission: "")
      customer = Stripe::Customer.create(
        name: name,
        email: email,
        phone: stripe_phone_number,
        source: stripe_token
      )

      user.update(stripe_id: customer.id)

      # amount needs to be in cents for Stripe
      amount_in_cents = params[:amount].to_i
      amount = amount_in_cents / 100

      customer_ip = params[:customer_ip]

      stripe_charge = Stripe::Charge.create(
        amount: amount_in_cents,
        currency: "usd",
        customer: customer.id,
        description: "One-time contribution."
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
          user_id: user.id,
          # TODO: add address
          user_data: {
            name: name,
            email: email,
            phone_number: phone_number
          }
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
      phone_number = params[:phone_number].to_s
      stripe_token = params[:stripe_token]
      valid_email = ValidEmail2::Address.new(email).valid?

      if name.blank? || !valid_email || phone_number.blank?
        return [nil, "Please make sure all fields are valid"]
      end

      # checking if a card was given.
      if stripe_token.blank?
        Raven.capture_message("We couldn't process payment for user_id: #{user.id}", extra: {params: params})
        error = "We couldn't process your payment, please try again or contact us at admin@debtcollective.org for support"

        return nil, error
      end

      # Stripe max length for the phone field is 20
      stripe_phone_number = phone_number.truncate(20, omission: "")
      customer = Stripe::Customer.create(
        name: name,
        email: email,
        phone: stripe_phone_number,
        source: stripe_token
      )

      # amount needs to be in cents for Stripe
      amount_in_cents = params[:amount].to_i
      amount = amount_in_cents / 100

      customer_ip = params[:customer_ip]

      stripe_charge = Stripe::Charge.create(
        customer: customer.id,
        amount: amount_in_cents,
        description: "One time contribution",
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
          # TODO: add address
          user_data: {
            name: name,
            email: email,
            phone_number: phone_number
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
