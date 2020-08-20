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

    if amount_cents < 500
      flash[:error] = I18n.t("charge.errors.min_amount")

      return render :new
    end

    donation_params = params.merge({amount: amount_cents, customer_ip: request.remote_ip})

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

  def charges_params
    params.require(:donation).permit(:amount)
  end
end
