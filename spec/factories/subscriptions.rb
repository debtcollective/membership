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
FactoryBot.define do
  factory :subscription do
    active { true }
    user
    plan
  end
end
