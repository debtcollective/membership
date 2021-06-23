class MembershipService
  include ActiveModel::Validations

  attr_reader :user
  attr_accessor :address_city,
    :address_country_code,
    :address_line1,
    :address_state,
    :address_zip,
    :amount,
    :chapter,
    :customer_ip,
    :email,
    :name,
    :first_name,
    :last_name,
    :phone_number,
    :stripe_customer,
    :stripe_phone_number,
    :stripe_token

  validates :name, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, 'valid_email_2/email': true
  validates :customer_ip, presence: true
  validates :amount, presence: true
  validates_numericality_of :amount, only_integer: true
  validates_numericality_of :amount, greater_than_or_equal_to: 5, unless: proc { |service| service.amount == 0 }
  validates :stripe_token, presence: true, unless: proc { |service| service.amount == 0 }

  def initialize(params, user = nil)
    params.each { |k, v| send("#{k}=", v) }

    # amount needs to be int, but only cast it if present
    if params[:amount].present?
      self.amount = params[:amount].to_i
    end

    # normalize email
    self.email = params[:email].downcase

    @user = user
  end

  def execute
    return Subscription.new, errors unless valid?

    @user ||= find_or_create_user

    # check if the user has a valid subscription already
    if Subscription.exists?(user_id: user.id, status: :active)
      errors.add(:base, I18n.t("subscription.errors.active_subscription"))

      return Subscription.new, errors
    end

    user_profile = update_user_profile(@user)

    if user_profile.errors.any?
      return Subscription.new, user_profile.errors
    end

    # queue location data job
    AddLocationDataToUserProfileJob.perform_later(user_id: @user.id)

    # handle creating a membership with the zero-amount option we are offering
    # create a membership but don't create a donation or stripe charge
    if amount == 0
      subscription = Subscription.create(user_id: user.id, status: :active, amount: amount, last_charge_at: nil)
    else
      # find stripe customer
      @stripe_customer = user.find_stripe_customer

      if @stripe_customer.present?
        # update default source for stripe customer
        Stripe::Customer.update(@stripe_customer.id, source: stripe_token)
      else
        params = {
          name: name,
          email: email,
          source: stripe_token
        }

        @stripe_customer = Stripe::Customer.create(params)

        user.update!(stripe_id: @stripe_customer.id)
      end

      subscription = create_paid_membership
    end

    link_discourse_account
    subscription.subscribe_user_to_newsletter

    [subscription, errors]
  end

  def create_paid_membership
    stripe_charge, error = create_stripe_charge

    if error
      errors.add(:base, error)

      return Subscription.new
    end

    # create subscription and the first donation
    subscription = Subscription.create(user_id: user.id, status: :active, amount: amount, last_charge_at: DateTime.now)

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
        user_id: user.id
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
      user.registration_ip_address = customer_ip
    end
  end

  def update_user_profile(user = self.user)
    user_profile = user.find_or_create_user_profile

    user_profile.first_name = first_name
    user_profile.last_name = last_name
    user_profile.address_city = address_city
    user_profile.address_country_code = address_country_code
    user_profile.address_country = ISO3166::Country[address_country_code]&.name
    user_profile.address_line1 = address_line1
    user_profile.address_zip = address_zip
    user_profile.registration_email ||= email
    user_profile.phone_number = phone_number

    user_profile.save

    user_profile
  end

  def link_discourse_account
    LinkDiscourseAccountJob.perform_later(user)
  end
end
