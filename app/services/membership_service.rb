class MembershipService
  include ActiveModel::Validations

  attr_reader :user
  attr_accessor :address_city,
    :address_country_code,
    :address_line1,
    :address_zip,
    :amount,
    :chapter,
    :customer_ip,
    :email,
    :name,
    :phone_number,
    :stripe_phone_number,
    :stripe_token,
    :stripe_customer

  validates :name, presence: true
  validates :email, presence: true, 'valid_email_2/email': true
  validates :phone_number, presence: true
  validates :amount, presence: true
  validates_numericality_of :amount, only_integer: true
  validates_numericality_of :amount, greater_than_or_equal_to: 5, unless: proc { |service| service.amount == 0 }
  validates :stripe_token, presence: true, unless: proc { |service| service.amount == 0 }
  validates :address_line1, presence: true
  validates :chapter, inclusion: {in: ["pennsylvania", "massachusetts", "dc", "chicago", "san diego"]}, allow_blank: true
  validates :address_city, presence: true
  validates :address_zip, presence: true
  validates :address_country_code,
    presence: true,
    inclusion: {in: ISO3166::Country.all.map(&:alpha2)}
  validates :customer_ip, presence: true

  def initialize(params, user = nil)
    params.each { |k, v| send("#{k}=", v) }

    # amount needs to be int
    self.amount = params[:amount].to_i

    @user = user
  end

  def execute
    return Subscription.new, errors unless valid?

    # find or create user if no user was provided
    if user.nil?
      @user = find_or_create_user
    else
      update_user_profile(user)
    end

    # validate active subscription
    if Subscription.exists?(user_id: user.id, active: true)
      errors.add(:base, I18n.t("subscription.errors.active_subscription"))

      return Subscription.new, errors
    end

    # handle creating a membership with the zero-amount option we are offering
    # create a membership but don't create a donation or stripe charge
    if amount == 0
      subscription = Subscription.create(user_id: user.id, active: true, amount: amount, last_charge_at: nil)
    else
      # Stripe max length for the phone field is 20
      self.stripe_phone_number = phone_number.truncate(20, omission: "")
      # find or create stripe customer
      @stripe_customer = user.find_or_create_stripe_customer

      if @stripe_customer.nil?
        errors.add(:base, user.errors.full_messages.first)

        Raven.capture_message("Couldn't find or create Stripe Customer", extra: {
          user_id: user.id,
          user_email: user.email,
          error_message: errors[:base]
        })

        return Subscription.new, errors
      end

      subscription = create_paid_membership
    end

    # Invite user to Discourse or send verification email
    link_discourse_account

    [subscription, errors]
  end

  def create_paid_membership
    stripe_charge, error = create_stripe_charge

    if error
      errors.add(:base, error)

      return Subscription.new
    end

    # create subscription and the first donation
    subscription = Subscription.create(user_id: user.id, active: true, amount: amount, last_charge_at: DateTime.now)

    donation =
      subscription.donations.new(
        amount: amount,
        charge_data: JSON.parse(stripe_charge.to_json),
        charge_id: stripe_charge.id,
        charge_provider: "stripe",
        customer_ip: customer_ip,
        customer_stripe_id: stripe_customer.id,
        donation_type: Donation::DONATION_TYPES[:subscription],
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

    donation.save!

    subscription
  end

  private

  def create_stripe_charge
    # amount needs to be in cents for Stripe
    amount_in_cents = amount * 100

    [Stripe::Charge.create(
      customer: stripe_customer.id,
      amount: amount_in_cents,
      description: "One time contribution",
      currency: "usd"
    ), nil]
  rescue Stripe::StripeError => e
    [nil, e.message]
  end

  def find_or_create_user
    User.find_or_create_by(email: email) do |user|
      update_user_profile(user)
    end
  end

  def update_user_profile(user = self.user)
    user.name = name
    user.custom_fields = {
      address_city: address_city,
      address_country: ISO3166::Country[address_country_code].name,
      address_country_code: address_country_code,
      address_line1: address_line1,
      address_zip: address_zip,
      chapter: chapter,
      email: email,
      name: name,
      phone_number: phone_number
    }

    user.save
  end

  def link_discourse_account
    LinkDiscourseAccountJob.perform_later(user)
  end
end
