# frozen_string_literal: tr

class DonationService
  include ActiveModel::Validations

  attr_accesor :name,
               :email,
               :phone_number,
               :amount,
               :stripe_token,
               :fund_id,
               :address_line1,
               :address_city,
               :address_country,
               :address_zip,
               :user

  validates :name, presence: true
  validates :email, presence: true, format: :email
  validates :phone_number, presence: true
  validates :amount, presence: true
  validates :stripe_token, presence: true
  validates :fund_id, presence: true
  validates :address_line1, presence: true
  validates :address_city, presence: true
  validates :address_zip, presence: true
  validates :address_country, presence: true
  validates :customer_ip, presence: true

  def intialize(params, user)
    params.keys.each { |key| send("#{key}=", params[key]) }

    self.user = user
  end

  def save_donation_with_user
    return errors.full_messages unless valid?

    # Stripe max length for the phone field is 20
    stripe_phone_number = phone_number.truncate(20, omission: '')
    customer =
      Stripe::Customer.create(
        name: name,
        email: email,
        phone: stripe_phone_number,
        source: stripe_token
      )

    user.update(stripe_id: customer.id)

    # amount needs to be in cents for Stripe
    amount_in_cents = amount.to_i

    stripe_charge =
      Stripe::Charge.create(
        amount: amount_in_cents,
        currency: 'usd',
        customer: customer.id,
        description: 'One-time contribution.'
      )

    if stripe_charge
      donation =
        Donation.new(
          amount: amount,
          charge_data: JSON.parse(stripe_charge.to_json),
          charge_id: stripe_charge.id,
          charge_provider: 'stripe',
          customer_ip: customer_ip,
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          fund_id: params[:fund_id],
          status: stripe_charge.status,
          user_id: user.id,
          user_data: {
            name: name,
            email: email,
            phone_number: phone_number,
            address_line1: address_line1,
            address_city: address_city,
            address_zip: address_zip,
            address_country: address_country
          }
        )

      donation.save

      return donation
    end

    false
  rescue Stripe::StripeError => e
    Raven.capture_exception(e)

    errors.add(:base, e.message)

    self
  end

  def save_donation_without_user(params)
    name = params[:name]
    email = params[:email]
    fund_id = params[:fund_id]
    phone_number = params[:phone_number].to_s
    stripe_token = params[:stripe_token]
    valid_email = ValidEmail2::Address.new(email).valid?

    if name.blank? || !valid_email || phone_number.blank?
      return nil, 'Please make sure all fields are valid'
    end

    # checking if a card was given.
    if stripe_token.blank?
      Raven.capture_message(
        "We couldn't process payment for user_id: #{user.id}",
        extra: { params: params }
      )
      error =
        "We couldn't process your payment, please try again or contact us at admin@debtcollective.org for support"

      return nil, error
    end

    # Stripe max length for the phone field is 20
    stripe_phone_number = phone_number.truncate(20, omission: '')
    customer =
      Stripe::Customer.create(
        name: name,
        email: email,
        phone: stripe_phone_number,
        source: stripe_token
      )

    # amount needs to be in cents for Stripe
    amount_in_cents = params[:amount].to_i
    amount = amount_in_cents / 100

    customer_ip = params[:customer_ip]

    stripe_charge =
      Stripe::Charge.create(
        customer: customer.id,
        amount: amount_in_cents,
        description: 'One time contribution',
        currency: 'usd'
      )

    if stripe_charge
      donation =
        Donation.new(
          amount: amount,
          charge_data: JSON.parse(stripe_charge.to_json),
          charge_id: stripe_charge.id,
          charge_provider: 'stripe',
          customer_ip: customer_ip,
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          fund_id: fund_id,
          status: stripe_charge.status,
          user_data: {
            # TODO: add address
            name: name,
            email: email,
            phone_number: phone_number
          }
        )

      donation.save

      return donation
    end

    [false, nil]
  rescue Stripe::StripeError => e
    Raven.capture_exception(e)

    [nil, e.message]
  end

  def displayable_amount(amount)
    return '$0' unless amount

    ActionController::Base.helpers.number_to_currency(amount.to_f / 100)
  end
end
