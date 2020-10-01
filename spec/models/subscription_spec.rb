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
require "rails_helper"

RSpec.describe Subscription, type: :model do
  let(:subscription) { FactoryBot.create(:subscription) }
  let(:plan) { FactoryBot.create(:plan) }

  subject { subscription }

  describe "attributes" do
    it { is_expected.to respond_to(:user_id) }
    it { is_expected.to respond_to(:plan_id) }
    it { is_expected.to respond_to(:active) }
    it { is_expected.to be_valid }
  end

  describe "validations" do
    it { should belong_to(:user).optional(true) }
    it { should have_many(:donations) }

    it "can have many subscriptions" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:subscription, user: user, active: false)

      new_subscription = Subscription.new(
        user_id: user.id,
        plan_id: plan.id,
        active: true
      )

      new_subscription.save

      expect(new_subscription.errors).to be_empty
    end

    it "can have only one active subscription at a time" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:subscription, user: user)

      new_subscription = Subscription.new(
        user_id: user.id,
        plan_id: plan.id,
        active: true
      )

      new_subscription.save

      expect(new_subscription.errors.full_messages).to eq(["already has an active subscription"])
    end
  end

  describe ".overdue?" do
    it "returns true if subscription.last_charge_at is nil" do
      subscription = FactoryBot.create(:subscription)

      expect(subscription.last_charge_at).to be_nil
      expect(subscription.overdue?).to eq(true)
    end

    it "returns true if subscription.last_charge_at is beyond grace period" do
      subscription = FactoryBot.create(:subscription, last_charge_at: 2.months.ago, active: true)

      expect(subscription.last_charge_at.to_i).to be_within(100).of(2.months.ago.to_i)
      expect(subscription.overdue?).to eq(true)
    end

    it "returns false if subscription is not overdue" do
      subscription = FactoryBot.create(:subscription_with_donation)

      expect(subscription.last_charge_at.to_i).to be_within(100).of(DateTime.now.to_i)
      expect(subscription.overdue?).to eq(false)
    end
  end

  describe ".beyond_grace_period?" do
    it "returns false if subscription is not overdue" do
      subscription = FactoryBot.create(:subscription_with_donation)

      expect(subscription.overdue?).to eq(false)
      expect(subscription.beyond_grace_period?).to eq(false)
    end

    it "returns true if subscription.last_charge_at is beyond grace period" do
      last_charge_at = (Subscription::SUBSCRIPTION_PERIOD + Subscription::GRACE_PERIOD + 1.day).ago
      subscription = FactoryBot.create(:subscription, last_charge_at: last_charge_at)

      expect(subscription.beyond_grace_period?).to eq(true)
    end
  end

  describe ".zero_amount?" do
    it "returns true if subscription amount is zero" do
      subscription = FactoryBot.build(:subscription, amount: 0)

      expect(subscription.zero_amount?).to eq(true)
    end
  end
end
