# frozen_string_literal: true

require 'recaptcha'

class ChargesController < ApplicationController
  before_action :set_amount, only: [:create]

  def new; end

  def create
    return unless verify_recaptcha
    return if @amount.nil? || @amount.zero? || @amount.negative?

    if @amount < 500
      Raven.capture_message("#{current_user&.id ? "We couldn't process payment for user_id: #{current_user.id}. " : ''} To increase the security of our payment provider integration, the minimum amount that can be donated is $5 USD", extra: { params: params })
      return
    end

    charge = current_user ? save_donation_from(current_user, params) : charge_donation_of_anonymous_user(params)
    notice = "Thank you for donating #{displayable_amount(@amount)}."

    if charge.instance_of?(String)
      flash[:error] = charge
      redirect_to new_charge_path
      return
    end

    if current_user
      redirect_to user_path(current_user), notice: notice
    else
      redirect_to root_path, notice: notice
    end
  end

  protected

  def displayable_amount(amount)
    return '$0' unless amount

    ActionController::Base.helpers.number_to_currency(amount.to_f / 100)
  end

  private

  def save_donation_from(user, params)
    if user.stripe_id.nil?
      customer = Stripe::Customer.create("email": user.email, source: params[:stripeToken])
      # here we are creating a stripe customer with the help of the Stripe
      # library and pass as parameter email.
      user.update(stripe_id: customer.id)
      # we are updating @user and giving to it stripe_id which is equal to
      # id of customer on Stripe
    end

    card_token = params[:stripeToken]
    # it's the stripeToken that we added in the hidden input

    # checking if a card was given.
    if card_token.nil?
      Raven.capture_message("We couldn't process payment for user_id: #{user.id}", extra: { params: params })
      redirect_to billing_path, error: "We couldn't process your payment, please try again or contact us at admin@debtcollective.org for support"
    end

    charge = Stripe::Charge.create(
      customer: user.stripe_id,
      amount: @amount,
      description: "One time donation of #{displayable_amount(@amount)}",
      currency: 'usd'
    )

    if charge
      donation = Donation.new(
        amount: @amount / 100, # transformed from cents
        customer_stripe_id: user.stripe_id,
        donation_type: Donation::DONATION_TYPES[:one_off],
        customer_ip: request.remote_ip,
        user_id: current_user.id
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

    charge = Stripe::Charge.create(
      customer: customer.id,
      amount: @amount,
      description: "One time donation of #{displayable_amount(@amount)}",
      currency: 'usd'
    )

    if charge
      donation = Donation.new(
        amount: @amount / 100, # transformed from cents
        customer_stripe_id: customer.id,
        donation_type: Donation::DONATION_TYPES[:one_off],
        customer_ip: request.remote_ip
      )

      return donation.save
    end
    false
  rescue Stripe::StripeError => e
    e.message
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_amount
    # Amount in cents
    @amount = charges_params[:amount].to_i * 100
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def charges_params
    params.require(:donation).permit(:amount)
  end
end
