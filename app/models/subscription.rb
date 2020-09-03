# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id             :bigint           not null, primary key
#  active         :boolean
#  last_charge_at :datetime
#  start_date     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  plan_id        :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_subscriptions_on_plan_id                         (plan_id)
#  index_subscriptions_on_user_id                         (user_id)
#  index_subscriptions_on_user_id_and_plan_id_and_active  (user_id,plan_id,active) UNIQUE
#
class Subscription < ApplicationRecord
  before_create :store_start_date

  belongs_to :user, optional: true
  belongs_to :plan

  validates :plan_id, presence: true
  validates :user_id, uniqueness: {scope: %i[plan_id active]}, if: :user?

  def user?
    !user_id.blank?
  end

  def cancel!
    self.active = false

    save
  end

  private

  def store_start_date
    self.start_date = DateTime.now if start_date.nil?
  end
end
