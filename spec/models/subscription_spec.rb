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
require "rails_helper"

RSpec.describe Subscription, type: :model do
  let(:subscription) { FactoryBot.create(:subscription) }

  subject { subscription }

  describe "attributes" do
    it { is_expected.to respond_to(:user_id) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to("active?") }
    it { is_expected.to respond_to("overdue?") }
    it { is_expected.to be_valid }
  end

  describe "validations" do
    it { should belong_to(:user).optional(true) }
    it { should have_many(:donations) }

    it "can have many subscriptions" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:subscription, user: user, status: :canceled)

      new_subscription = Subscription.new(
        user_id: user.id,
        amount: 20,
        status: :active
      )

      new_subscription.save

      expect(new_subscription.errors).to be_empty
    end

    it "can have only one active subscription at a time" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:subscription, user: user)

      new_subscription = Subscription.new(
        user_id: user.id,
        amount: 20,
        status: :active
      )

      new_subscription.save

      expect(new_subscription.errors.full_messages).to eq(["already has an active subscription"])
    end
  end

  describe ".failed_charge_count" do
    it "gets and sets the counter" do
      subscription = FactoryBot.create(:subscription)

      expect(subscription.failed_charge_count).to eq(0)

      subscription.failed_charge_count = subscription.failed_charge_count + 1
      subscription.save

      expect(subscription.failed_charge_count).to eq(1)
    end
  end

  describe ".overdue?" do
    it "returns true if subscription.last_charge_at is nil" do
      subscription = FactoryBot.create(:subscription)

      expect(subscription.last_charge_at).to be_nil
      expect(subscription.overdue?).to eq(true)
    end

    it "returns true if subscription.last_charge_at is beyond grace period" do
      subscription = FactoryBot.create(:subscription, last_charge_at: 2.months.ago, status: :active)

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

    it "returns false if the failed charge count is less than the limit" do
      subscription = FactoryBot.create(:subscription_overdue, metadata: {failed_charge_count: Subscription::FAILED_CHARGE_COUNT_BEFORE_DISABLE - 1})

      expect(subscription.overdue?).to eq(true)
      expect(subscription.beyond_grace_period?).to eq(false)
    end

    it "returns true if the failed charge count is more than the limit" do
      subscription = FactoryBot.create(:subscription_beyond_grace_period)

      expect(subscription.overdue?).to eq(true)
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
