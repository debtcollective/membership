# frozen_string_literal: tr

class DonationService
  include ActiveModel::Validations

  attr_reader :user
  attr_accessor :address_city,
    :address_country_code,
    :address_line1,
    :address_zip,
    :amount,
    :customer_ip,
    :donation_type,
    :email,
    :fund_id,
    :name,
    :phone_number,
    :stripe_phone_number,
    :stripe_token

  validates :name, presence: true
  validates :email, presence: true, 'valid_email_2/email': true
  validates :phone_number, presence: true
  validates :amount, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 5}
  validates :stripe_token, presence: true
  validates :fund_id, presence: true
  validates :address_line1, presence: true
  validates :donation_type, presence: true, inclusion: {in: %w[one_off subscription]}
  validates :address_city, presence: true
  validates :address_zip, presence: true
  validates :address_country_code,
    presence: true,
    inclusion: {in: ISO3166::Country.all.map(&:alpha2)}
  validates :customer_ip, presence: true

  def initialize(params, user = nil)
    params.each { |k, v| send("#{k}=", v) }

    # amount needs to be converted to int
    self.amount = params[:amount].to_i

    # donation can be one_time or monthly
    self.donation_type ||= "one_off"

    @user = user
  end

  def execute
    return Donation.new, errors unless valid?

    # Stripe max length for the phone field is 20
    self.stripe_phone_number = phone_number.truncate(20, omission: "")

    if donation_type == "one_off"
      !!user ? save_donation_with_user : save_donation_without_user
    else
      create_recurring_donation
    end
  end

  def save_donation_with_user
    customer =
      Stripe::Customer.create(
        name: name,
        email: email,
        phone: stripe_phone_number,
        source: stripe_token
      )

    user.update(stripe_id: customer.id)

    # amount needs to be in cents for Stripe
    amount_in_cents = amount * 100

    stripe_charge =
      Stripe::Charge.create(
        amount: amount_in_cents,
        currency: "usd",
        customer: customer.id,
        description: "One-time contribution."
      )

    if stripe_charge
      donation =
        Donation.new(
          amount: amount,
          charge_data: JSON.parse(stripe_charge.to_json),
          charge_id: stripe_charge.id,
          charge_provider: "stripe",
          customer_ip: customer_ip,
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          fund_id: fund_id,
          status: stripe_charge.status,
          user_id: user.id,
          user_data: {
            address_city: address_city,
            address_country: ISO3166::Country[address_country_code].name,
            address_country_code: address_country_code,
            address_line1: address_line1,
            address_zip: address_zip,
            email: email,
            name: name,
            phone_number: phone_number
          }
        )

      donation.save

      [donation, errors]
    end
  rescue Stripe::StripeError => e
    Raven.capture_exception(e)

    errors.add(:base, e.message)

    [Donation.new, errors]
  end

  def save_donation_without_user
    customer =
      Stripe::Customer.create(
        name: name,
        email: email,
        phone: stripe_phone_number,
        source: stripe_token
      )

    # amount needs to be in cents for Stripe
    amount_in_cents = amount * 100

    stripe_charge =
      Stripe::Charge.create(
        customer: customer.id,
        amount: amount_in_cents,
        description: "One time contribution",
        currency: "usd"
      )

    if stripe_charge
      donation =
        Donation.new(
          amount: amount,
          charge_data: JSON.parse(stripe_charge.to_json),
          charge_id: stripe_charge.id,
          charge_provider: "stripe",
          customer_ip: customer_ip,
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:one_off],
          fund_id: fund_id,
          status: stripe_charge.status,
          user_data: {
            address_city: address_city,
            address_country: ISO3166::Country[address_country_code].name,
            address_country_code: address_country_code,
            address_line1: address_line1,
            address_zip: address_zip,
            email: email,
            name: name,
            phone_number: phone_number
          }
        )

      donation.save

      [donation, errors]
    end
  rescue Stripe::StripeError => e
    Raven.capture_exception(e)

    errors.add(:base, e.message)

    [Donation.new, errors]
  end

  def create_recurring_donation
    @user = create_user unless !!user

    stripe_customer_id = user.stripe_id

    if stripe_customer_id
      customer = Stripe::Customer.retrieve(user.stripe_id)

      # add source to customer
      Stripe::Customer.create_source(
        stripe_customer_id,
        {
          source: stripe_token
        }
      )

      # make the source we just added the default one
      Stripe::Customer.update(
        stripe_customer_id,
        {
          source: stripe_token
        }
      )
    else
      customer =
        Stripe::Customer.create(
          name: name,
          email: email,
          phone: stripe_phone_number,
          source: stripe_token
        )
    end

    # amount needs to be in cents for Stripe
    amount_in_cents = amount * 100

    stripe_charge =
      Stripe::Charge.create(
        customer: customer.id,
        amount: amount_in_cents,
        description: "One time contribution",
        currency: "usd"
      )

    if stripe_charge
      donation =
        Donation.new(
          amount: amount,
          charge_data: JSON.parse(stripe_charge.to_json),
          charge_id: stripe_charge.id,
          charge_provider: "stripe",
          customer_ip: customer_ip,
          customer_stripe_id: customer.id,
          donation_type: Donation::DONATION_TYPES[:subscription],
          fund_id: fund_id,
          status: stripe_charge.status,
          user_id: user.id,
          user_data: {
            address_city: address_city,
            address_country: ISO3166::Country[address_country_code].name,
            address_country_code: address_country_code,
            address_line1: address_line1,
            address_zip: address_zip,
            email: email,
            name: name,
            phone_number: phone_number
          }
        )

      donation.save

      # Create subscription
      Subscription.create(user_id: user.id, active: true, amount: amount, last_charge_at: DateTime.now)

      # Update stripe customer id
      @user.update(stripe_id: customer.id)

      [donation, errors]
    end
  rescue Stripe::StripeError => e
    Raven.capture_exception(e)

    errors.add(:base, e.message)

    [Subscription.new, errors]
  end

  private

  def create_user
    User.create({
      name: name,
      email: email,
      custom_fields: {
        address_city: address_city,
        address_country: ISO3166::Country[address_country_code].name,
        address_country_code: address_country_code,
        address_line1: address_line1,
        address_zip: address_zip,
        email: email,
        name: name,
        phone_number: phone_number
      }
    })
  end
end