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
FactoryBot.define do
  factory :subscription do
    active { true }
    amount { (5..100).to_a.sample }
    user

    factory :subscription_with_donation do
      after(:create) do |subscription|
        donation = FactoryBot.create(:donation, subscription: subscription, amount: subscription.amount.to_i)

        subscription.update(last_charge_at: donation.created_at)
      end
    end

    factory :subscription_overdue do
      last_charge_at { (Subscription::SUBSCRIPTION_PERIOD + 1.day).ago }
    end

    factory :subscription_beyond_grace_period do
      last_charge_at { (Subscription::SUBSCRIPTION_PERIOD + Subscription::GRACE_PERIOD + 1.day).ago }

      after(:create) do |subscription|
        FactoryBot.create(:donation, subscription: subscription, amount: subscription.amount.to_i, created_at: subscription.last_charge_at)
      end
    end
  end
end
