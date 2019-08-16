# frozen_string_literal: true

class Admin::SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[show edit update destroy]

  # GET /admin/subscriptions
  # GET /admin/subscriptions.json
  def index
    @subscriptions = Subscription.all
  end

  # GET /admin/subscriptions/1
  # GET /admin/subscriptions/1.json
  def show; end

  # GET /admin/subscriptions/new
  def new
    @subscription = Subscription.new
  end

  # GET /admin/subscriptions/1/edit
  def edit; end

  # PATCH/PUT /admin/subscriptions/1
  # PATCH/PUT /admin/subscriptions/1.json
  def update
    respond_to do |format|
      if @subscription.update(subscription_params)
        format.html { redirect_to admin_subscription_url(@subscription), notice: 'Subscription was successfully updated.' }
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { render :edit }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/subscriptions/1
  # DELETE /admin/subscriptions/1.json
  def destroy
    @subscription.destroy
    respond_to do |format|
      format.html { redirect_to admin_subscriptions_url, notice: 'Subscription was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subscription_params
    params.require(:subscription).permit(:user_id, :plan_id, :active)
  end
end
