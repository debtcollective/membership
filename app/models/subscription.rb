# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id             :bigint           not null, primary key
#  amount         :money            default(0.0)
#  last_charge_at :datetime
#  metadata       :jsonb            not null
#  start_date     :datetime
#  status         :string           default("active"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint
#
# Indexes
#
#  index_subscriptions_on_user_id  (user_id)
#
class SubscriptionNotOverdueError < StandardError
  def initialize(subscription, msg = "The subscription you are trying to charge is not due")
    @subscription = subscription
    super(msg)
  end

  def raven_context
    {subscription_id: subscription.id}
  end
end

class Subscription < ApplicationRecord
  # TODO: remove this after we run the migrations correctly on production and we can delete the `active :boolean` column
  self.ignored_columns = ["active"]

  has_paper_trail(
    only: [:amount, :status]
  )

  FAILED_CHARGE_COUNT_BEFORE_OVERDUE = 1
  SUBSCRIPTION_PERIOD = 1.month

  # Mailchimp tags
  ZERO_AMOUNT_TAG = "Zero-dollar Members"
  DUES_PAYING_TAG = "Dues-Paying Members"
  MEMBER_TAG = "Union Member"

  # We do it like this to support strings instead of numbers in the status db column
  enum status: {active: "active", paused: "paused", overdue: "overdue", canceled: "canceled", inactive: "inactive"}

  before_create :store_start_date

  belongs_to :user, optional: true
  has_many :donations

  validate :only_one_active_subscription, on: :create
  validates_numericality_of :amount, greater_than_or_equal_to: 5, unless: proc { |service| service.amount == 0 }

  def self.due
    where(status: :active).where(
      "last_charge_at IS NULL OR last_charge_at <= ?",
      SUBSCRIPTION_PERIOD.ago
    ).where.not(amount: 0)
  end

  def beyond_subscription_period?
    return false if zero_amount?
    return true if last_charge_at.nil?

    last_charge_at <= (SUBSCRIPTION_PERIOD + 1.day).ago
  end

  def should_charge?
    if active? && beyond_subscription_period?
      return true
    end

    paused? || overdue?
  end

  def user?
    !user_id.blank?
  end

  def zero_amount?
    amount == 0
  end

  def beyond_grace_period?
    failed_charge_count >= FAILED_CHARGE_COUNT_BEFORE_OVERDUE
  end

  def subscribe_user_to_newsletter
    return unless user?

    membership_type_tag = zero_amount? ? ZERO_AMOUNT_TAG : DUES_PAYING_TAG
    tags = [{name: membership_type_tag, status: "active"}, {name: MEMBER_TAG, status: "active"}]

    SubscribeUserToNewsletterJob.perform_later(user_id: user.id, tags: tags)
  end

  def card_last4
    metadata["payment_method"]&.[]("last4")
  end

  def update_credit_card!(params)
    customer = user.find_stripe_customer

    return false unless customer

    # Update card on Stripe
    customer = Stripe::Customer.update(
      customer.id,
      {
        address: {
          city: params[:address_city],
          country: params[:address_country],
          line1: params[:address_line1],
          postal_code: params[:address_zip],
          state: params[:address_state]
        },
        name: "#{params[:first_name]} #{params[:last_name]}",
        source: params[:stripe_token]
      }
    )

    self.metadata = {
      payment_provider: "stripe",
      payment_method: {
        type: "card",
        last4: params[:stripe_card_last4],
        card_id: params[:stripe_card_id],
        customer_id: customer.id
      }
    }

    save
  end

  def failed_charge_count
    metadata["failed_charge_count"].to_i
  end

  def failed_charge_count=(count)
    metadata["failed_charge_count"] = count
  end

  def next_payment_due_at
    today = Date.today

    if last_charge_at.nil?
      today
    else
      next_payment_date = last_charge_at + SUBSCRIPTION_PERIOD

      return today if next_payment_date < today

      next_payment_date
    end
  end

  # Creates a Stripe::Charge using the current payment method on the Stripe::Customer
  # returns true if the charge was successful
  def charge!
    raise SubscriptionNotOverdueError.new(self) unless beyond_subscription_period?

    customer = user.find_stripe_customer
    client = Stripe::StripeClient.new
    charge, _ = client.request {
      Stripe::Charge.create(
        customer: customer,
        amount: amount.to_i * 100,
        description: "Debt Collective membership monthly payment",
        currency: "usd",
        metadata: {subscription_id: id, user_id: user.id}
      )
    }

    if charge.paid?
      donation = donations.new(
        amount: charge.amount / 100,
        charge_data: JSON.parse(charge.to_json),
        customer_stripe_id: user.stripe_id || metadata["payment_method"]["customer_id"],
        donation_type: Donation::DONATION_TYPES[:subscription],
        status: charge.status,
        user: user,
        user_data: {email: user.email, name: user.name}
      )

      donation.save!

      # reset subscription failed_charge_count
      self.failed_charge_count = 0
      update!(last_charge_at: DateTime.now, status: :active)

      true
    else
      self.failed_charge_count = failed_charge_count + 1
      save

      handle_payment_failure

      false
    end
  rescue SubscriptionNotOverdueError
    # raise this error again
    raise
  rescue => e
    # capture Stripe errors or others
    Raven.capture_exception(e)
    handle_payment_failure

    false
  end

  private

  def handle_payment_failure
    MembershipMailer.payment_failure_email(user: user).deliver_later

    overdue! if beyond_subscription_period? && beyond_grace_period?
  end

  def store_start_date
    self.start_date = DateTime.now if start_date.nil?
  end

  def only_one_active_subscription
    return unless user?

    if Subscription.exists?(user_id: user_id, status: :active)
      errors.add(:base, "already has an active subscription")
    end
  end
end
