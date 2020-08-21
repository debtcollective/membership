# frozen_string_literal: true

require "recaptcha"

class ChargesController < ApplicationController
  def new
  end

  def create
    unless verify_recaptcha
      return render "new"
    end

    amount = charge_params[:amount].to_i

    if amount.nil? || amount.zero? || amount.negative?
      flash[:error] = "You must set a valid amount"
      return render :new
    end

    amount_cents = amount * 100
    if amount_cents < 500
      flash[:error] = I18n.t("charge.errors.min_amount")

      return render :new
    end

    donation_params = charge_params.to_h.merge({
      amount: amount_cents,
      customer_ip: request.remote_ip
    })

    donation, error = if current_user
      DonationService.save_donation_with_user(current_user, donation_params)
    else
      DonationService.save_donation_without_user(donation_params)
    end

    if error
      flash[:error] = error
      return render :new
    end

    if donation.instance_of?(String)
      flash[:error] = donation
      return render :new
    end

    # send thank you email
    DonationMailer.thank_you_email(donation: donation).deliver_later

    flash[:success] = I18n.t("charge.alerts.success", amount: DonationService.displayable_amount(amount_cents))
    redirect_to thank_you_path
  end

  private

  def charge_params
    params.require(:donation).permit(:name, :email, :amount, :stripe_token)
  end
end
