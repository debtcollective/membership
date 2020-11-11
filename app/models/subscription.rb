# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id             :bigint           not null, primary key
#  active         :boolean
#  amount         :money            default(0.0)
#  last_charge_at :datetime
#  start_date     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  plan_id        :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_subscriptions_on_plan_id  (plan_id)
#  index_subscriptions_on_user_id  (user_id)
#
class Subscription < ApplicationRecord
  GRACE_PERIOD = 7.days
  SUBSCRIPTION_PERIOD = 1.month

  before_create :store_start_date

  belongs_to :user, optional: true
  has_many :donations

  validate :only_one_active_subscription, on: :create

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
