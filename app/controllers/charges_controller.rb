# frozen_string_literal: true

require "recaptcha"

class ChargesController < ApplicationController
  def new
  end

  def create
    return unless verify_recaptcha

    amount = charges_params[:amount].to_i
    amount_cents = amount * 100

    if amount.nil? || amount.zero? || amount.negative?
      flash[:error] = "You must set a valid amount"
      return render :new
    end

    return Raven.capture_message(I18n.t("charge.errors.min_amount"), extra: {params: params}) if amount_cents < 500

    donation_params = params.merge({amount: amount_cents, customer_ip: request.remote_ip})

    charge, error = if current_user
      DonationService.save_donation_from(current_user, donation_params)
    else
      DonationService.charge_donation_of_anonymous_user(donation_params)
    end

    if error
      flash[:error] = error
      return render :new
    end

    if charge.instance_of?(String)
      flash[:error] = charge
      return render :new
    end

    flash[:success] = I18n.t("charge.alerts.success", amount: DonationService.displayable_amount(amount_cents))
    redirect_to thank_you_path
  end

  private

  def charges_params
    params.require(:donation).permit(:amount)
  end
end
