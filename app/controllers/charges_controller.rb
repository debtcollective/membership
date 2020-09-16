# frozen_string_literal: true

require "recaptcha"

class ChargesController < ApplicationController
  before_action :set_funds, only: %i[new create]
  before_action :set_fund_by_slug, only: :new
  before_action :set_fund_by_id, only: :create

  def new
  end

  def create
    return render "new" unless verify_recaptcha

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

    donation_params =
      charge_params.to_h.merge(
        {
          amount: amount_cents,
          customer_ip: request.remote_ip,
          fund_id: @fund.id
        }
      )

    donation, errors = DonationService.new(donation_params, current_user).execute

    if errors.any?
      flash[:error] = errors.full_messages.join(", ")
      return render :new
    end

    # send thank you email
    DonationMailer.thank_you_email(donation: donation).deliver_later

    flash[:success] =
      I18n.t(
        "charge.alerts.success",
        amount: DonationService.displayable_amount(amount_cents)
      )
    redirect_to thank_you_path
  end

  private

  def charge_params
    params.require(:charge).permit(
      :name,
      :email,
      :phone_number,
      :amount,
      :stripe_token,
      :fund_id,
      :address_line1,
      :address_city,
      :address_country_code,
      :address_zip
    )
  end

  def set_funds
    @funds = Fund.all
  end

  def set_fund_by_slug
    fund_slug = params[:fund]

    @fund = Fund.find_by(slug: fund_slug) if fund_slug
    @fund ||= Fund.default
  end

  def set_fund_by_id
    fund_id = charge_params[:fund_id]

    @fund = Fund.find_by(id: fund_id) if fund_id
    @fund ||= Fund.default
  end
end
