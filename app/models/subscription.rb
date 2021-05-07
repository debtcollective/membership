# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id             :bigint           not null, primary key
#  active         :boolean
#  amount         :money            default(0.0)
#  last_charge_at :datetime
#  metadata       :jsonb            not null
#  start_date     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint
#
# Indexes
#
#  index_subscriptions_on_user_id  (user_id)
#
class Subscription < ApplicationRecord
  GRACE_PERIOD = 7.days
  SUBSCRIPTION_PERIOD = 1.month

  # Mailchimp tags
  ZERO_AMOUNT_TAG = "Zero-dollar Members"
  DUES_PAYING_TAG = "Dues-Paying Members"
  MEMBER_TAG = "Union Member"

  before_create :store_start_date

  belongs_to :user, optional: true
  has_many :donations

  validate :only_one_active_subscription, on: :create
  validates_numericality_of :amount, greater_than_or_equal_to: 5, unless: proc { |service| service.amount == 0 }

  def self.overdue
    where(active: true).where(
      "last_charge_at IS NULL OR last_charge_at <= ?",
      SUBSCRIPTION_PERIOD.ago
    ).where.not(amount: 0)
  end

  def user?
    !user_id.blank?
  end

  def cancel!
    self.active = false

    save
  end

  def zero_amount?
    amount == 0
  end

  def pretty_status
    return "inactive" unless active?
    return "overdue" if overdue?

    "active"
  end

  def overdue?
    return false if zero_amount?
    return true if last_charge_at.nil?

    last_charge_at <= SUBSCRIPTION_PERIOD.ago
  end

  def beyond_grace_period?
    return false if zero_amount?
    return true if last_charge_at.nil?

    last_charge_at <= (SUBSCRIPTION_PERIOD + GRACE_PERIOD).ago
  end

  def disable!
    update!(active: false) if beyond_grace_period?
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

  private

  def store_start_date
    self.start_date = DateTime.now if start_date.nil?
  end

  def only_one_active_subscription
    return unless user?

    if Subscription.exists?(user_id: user_id, active: true)
      errors.add(:base, "already has an active subscription")
    end
  end
end
