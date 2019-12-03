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
        # here we are creating a stripe customer with the help of the Stripe
        # library and pass as parameter email.
        @user.update(stripe_id: customer.id)
        # we are updating @user and giving to it stripe_id which is equal to
        # id of customer on Stripe
      end

      card_token = params[:stripeToken]
      # it's the stripeToken that we added in the hidden input
      if card_token.nil?
        Raven.capture_message("We couldn't process payment for user_id: #{@user.id}", extra: { params: params })
        redirect_to billing_path, error: "We couldn't process your payment, please try again or contact us at admin@debtcollective.org for support"
      end
      # checking if a card was giving.

      customer = Stripe::Customer.new @user.stripe_id
      customer.source = card_token
      # we're attaching the card to the stripe customer
      customer.save

      # to get the data of the card that we need
      # we retrieve all customer cards from the Stripe stored customer data
      stripe_cards = Stripe::Customer.retrieve(@user.stripe_id)&.to_h[:sources]&.data

      unless stripe_cards.empty?
        # filter the ones from our database
        saved_cards = @user.cards.map(&:stripe_card_id)
        new_customer_cards = stripe_cards.reject { |stripe_card| (saved_cards.include? stripe_card.id) }

        new_customer_cards.each do |card|
          # add all new cards to our database
          Card.create(
            user_id: @user.id,
            brand: card.brand,
            exp_month: card.exp_month,
            exp_year: card.exp_year,
            last_digits: card.last4,
            stripe_card_id: card.id
          )
        end
      end

      format.html { redirect_to user_path(@user) }
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
