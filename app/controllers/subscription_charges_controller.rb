# frozen_string_literal: true

class SubscriptionChargesController < ApplicationController
  before_action :set_subscription, only: %i[edit update]
  before_action :set_current_plan, only: [:new]

  # GET /subscription_charges/new
  def new
    @subscription = Subscription.new(plan: @current_plan)
    @user = current_user || @subscription.build_user
  end

  # GET /subscription_charges/1/edit
  def edit
    @subscription = Subscription.find(params[:id])
    @user = @subscription.build_user
  end

  # POST /subscription_charges
  # POST /subscription_charges.json
  def create
    @user = current_user || User.create(subscription_params[:user_attributes])
    @subscription = Subscription.new(plan_id: subscription_params[:plan_attributes][:id], user_id: @user.id, active: true)

    customer = set_stripe_customer(@user, params[:stripeToken])

    amount = (@subscription.plan.amount * 100).to_i

    return unless verify_recaptcha(model: @subscription)

    charge = Stripe::Charge.create(
      customer: customer.id,
      amount: amount, # amount in cents
      description: "One time donation of #{displayable_amount(amount)}",
      currency: 'usd'
    )

    if charge
      @subscription.active = true
      @subscription.last_charge_at = DateTime.now
      @subscription.save

      Donation.create(
        amount: amount / 100, # transformed from cents
        customer_stripe_id: customer.id,
        donation_type: Donation::DONATION_TYPES[:subscription],
        customer_ip: request.remote_ip,
        user_id: @user.id
      )

      @user.update(stripe_id: customer.id) if @user.stripe_id.nil?

      respond_to do |format|
        format.html { redirect_to user_path(@user), notice: 'Thank you for subscribing.' }
        format.json { render :show, status: :created, location: @subscription }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def displayable_amount(amount)
    return '$0' unless amount

    ActionController::Base.helpers.number_to_currency(amount.to_f / 100)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def set_current_plan
    @current_plan = params[:plan_id] && Plan.find(params[:plan_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subscription_params
    params.require(:subscription).permit(:user_id, :plan_id, user_attributes: %i[name email], plan_attributes: [:id])
  end

  def set_stripe_customer(user, stripe_token)
    if user.stripe_id
      Stripe::Customer.retrieve(user.stripe_id)
    else
      Stripe::Customer.create(email: user.email, source: stripe_token)
    end
  end
end
