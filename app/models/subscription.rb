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
  before_create :store_start_date

  belongs_to :plan, optional: true
  belongs_to :user, optional: true
  has_many :donations

  validate :only_one_active_subscription, on: :create

  def user?
    !user_id.blank?
  end

  def cancel!
    self.active = false

    save
  end

  def self.overdue
    where(active: true).where(
      "last_charge_at IS NULL OR last_charge_at <= ?",
      30.days.ago
    ).where.not(amount: 0)
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
