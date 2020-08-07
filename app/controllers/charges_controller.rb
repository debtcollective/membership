# frozen_string_literal: true

require 'recaptcha'

class ChargesController < ApplicationController
  before_action :set_amount, only: [:create]

  def new; end

  def create
    return unless verify_recaptcha
    return if @amount.nil? || @amount.zero? || @amount.negative?

    return Raven.capture_message(I18n.t('charge.errors.min_amount'), extra: { params: params }) if @amount < 500

    charge = if current_user
               DonationService.save_donation_from(current_user, params)
             else
               DonationService.charge_donation_of_anonymous_user(params)
             end

    if charge.instance_of?(String)
      flash[:error] = charge
      return redirect_to new_charge_path
    end

    redirect_to thank_you_path
  end

  def thank_you; end

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
