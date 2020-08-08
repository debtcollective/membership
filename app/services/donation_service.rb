# frozen_string_literal: true

class DonationService
  class << self
    def save_donation_from(user, params)
      if user.stripe_id.nil?
        # here we are creating a stripe customer with the help of the Stripe
        # library and pass as parameter email.
        customer = Stripe::Customer.create("email": user.email, source: params[:stripeToken])
        # we are updating @user and giving to it stripe_id which is equal to
        # id of customer on Stripe
        user.update(stripe_id: customer.id)
      end

      amount = params[:amount]
      customer_ip = params[:customer_ip]

      card_token = params[:stripeToken]
      # it's the stripeToken that we added in the hidden input

      # checking if a card was given.
      if card_token.nil?
        Raven.capture_message("We couldn't process payment for user_id: #{user.id}", extra: { params: params })
        redirect_to billing_path, error: "We couldn't process your payment, please try again or contact us at admin@debtcollective.org for support"
      end

      charge = Stripe::Charge.create(
        customer: user.stripe_id,
        amount: amount,
        description: "One time donation of #{displayable_amount(amount)}",
        currency: 'usd'
      )

      if charge
        donation = Donation.new(
          amount: amount / 100, # transformed from cents
          customer_stripe_id: user.stripe_id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          customer_ip: customer_ip,
          user_id: user.id
        )

        return donation.save
      end

      false
    rescue Stripe::StripeError => e
      e.message
    end

    def charge_donation_of_anonymous_user(params)
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
        currency: 'usd'
      )

      if charge
        donation = Donation.new(
          amount: amount / 100, # transformed from cents
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          customer_ip: customer_ip
        )

        return donation.save
      end
      false
    rescue Stripe::StripeError => e
      Raven.capture_exception(e)
      e.message
    end

    def displayable_amount(amount)
      return '$0' unless amount

      ActionController::Base.helpers.number_to_currency(amount.to_f / 100)
    end
  end
end
