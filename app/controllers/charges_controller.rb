# frozen_string_literal: true

class ChargesController < ApplicationController
  before_action :set_amount, only: [:create]

  def new; end

  def create
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

    donation = Donation.new(
      amount: @amount / 100, # transformed from cents
      customer_stripe_id: customer.id,
      donation_type: Donation::DONATION_TYPES[:one_off],
      customer_ip: request.remote_ip
    )

    donation.user_id = @user.id if @user

    if donation.save!
      notice = "Thank you for donating #{displayable_amount(@amount)}."
      redirect_to user_path(current_user), notice: notice if current_user
      redirect_to root_path, notice: notice
    else
      redirect_to new_charge_path
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end

  protected

  def displayable_amount(amount)
    return '$0' unless amount

    ActionController::Base.helpers.number_to_currency(amount.to_f / 100)
  end

  private

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
