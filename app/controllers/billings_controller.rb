# frozen_string_literal: true

class BillingsController < ApplicationController
  before_action :set_user, only: %i[new new_card create_card]

  def new; end

  def create
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Subscription was successfully added.' }
      format.json { render :show, status: :created, location: @subscription }
    end
  end

  def create_card
    respond_to do |format|
      if @user.stripe_id.nil?
        customer = Stripe::Customer.create("email": @user.email)
        # here we are creating a stripe customer with the help of the Stripe library and pass as parameter email.
        @user.update(stripe_id: customer.id)
        # we are updating @user and giving to it stripe_id which is equal to id of customer on Stripe
      end

      card_token = params[:stripeToken]
      # it's the stripeToken that we added in the hidden input
      format.html { redirect_to billing_path, error: 'Oops' } if card_token.nil?
      # checking if a card was giving.

      customer = Stripe::Customer.new @user.stripe_id
      customer.source = card_token
      # we're attaching the card to the stripe customer
      customer.save

      format.html { redirect_to success_path }
    end
  end

  def new_card
    respond_to do |format|
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:user_id])
  end
end
