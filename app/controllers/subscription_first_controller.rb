# frozen_string_literal: true

class SubscriptionFirstController < ApplicationController
  before_action :set_subscription, only: %i[edit update]
  before_action :set_current_plan, only: [:new]

  # GET /subscription_first/new
  def new
    @subscription = Subscription.new(plan: @current_plan)
    @user = @subscription.user? ? @subscription.user : @subscription.build_user # TODO: Change for current_user
  end

  # GET /subscription_first/1/edit
  def edit
    @subscription = Subscription.find(params[:id])
    @user = @subscription.build_user
  end

  # POST /subscription_first
  # POST /subscription_first.json
  def create
    @user = User.create(subscription_params[:user_attributes])
    @subscription = Subscription.create(plan_id: subscription_params[:plan_attributes][:id], user_id: @user.id)

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to new_billing_path(user_id: @user.id) }
        format.json { render :show, status: :created, location: @subscription }
      else
        format.html { render :new }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
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
    params.require(:subscription).permit(:user_id, :plan_id, user_attributes: %i[first_name last_name email], plan_attributes: [:id])
  end
end
