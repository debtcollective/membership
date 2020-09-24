# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id             :bigint           not null, primary key
#  active         :boolean
#  amount         :money
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
    it { should belong_to(:plan).optional(true) }
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
end
