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
require "stripe_mock"

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

  describe ".beyond_subscription_period?" do
    it "returns true if subscription.last_charge_at is nil" do
      subscription = FactoryBot.create(:subscription)

      expect(subscription.last_charge_at).to be_nil
      expect(subscription.beyond_subscription_period?).to eq(true)
    end

    it "returns true if subscription.last_charge_at is beyond grace period" do
      subscription = FactoryBot.create(:subscription, last_charge_at: 2.months.ago, status: :active)

      expect(subscription.last_charge_at.to_i).to be_within(100).of(2.months.ago.to_i)
      expect(subscription.beyond_subscription_period?).to eq(true)
    end

    it "returns false if subscription is not beyond subscription period" do
      subscription = FactoryBot.create(:subscription_with_donation)

      expect(subscription.last_charge_at.to_i).to be_within(100).of(DateTime.now.to_i)
      expect(subscription.beyond_subscription_period?).to eq(false)
    end
  end

  describe ".beyond_grace_period?" do
    it "returns false if the failed charge count is less than the limit" do
      subscription = FactoryBot.create(:subscription_beyond_subscription_period, metadata: {failed_charge_count: Subscription::FAILED_CHARGE_COUNT_BEFORE_OVERDUE - 1})

      expect(subscription.beyond_grace_period?).to eq(false)
    end

    it "returns true if the failed charge count is more than the limit" do
      subscription = FactoryBot.create(:subscription_beyond_grace_period)

      expect(subscription.beyond_grace_period?).to eq(true)
    end
  end

  describe ".zero_amount?" do
    it "returns true if subscription amount is zero" do
      subscription = FactoryBot.build(:subscription, amount: 0)

      expect(subscription.zero_amount?).to eq(true)
    end
  end

  describe ".should_charge?" do
    it "returns true if subscription is paused" do
      subscription = FactoryBot.create(:subscription, status: :paused)

      expect(subscription.should_charge?).to eq(true)
    end

    it "returns true if subscription is overdue" do
      subscription = FactoryBot.create(:subscription, status: :overdue)

      expect(subscription.should_charge?).to eq(true)
    end

    it "returns false if subscription is canceled" do
      subscription = FactoryBot.create(:subscription, status: :canceled)

      expect(subscription.should_charge?).to eq(false)
    end

    it "returns false if subscription is free" do
      subscription = FactoryBot.create(:subscription, status: :active, amount: 0)

      expect(subscription.should_charge?).to eq(false)
    end

    it "returns false if subscription is active but is not beyond subscription period" do
      subscription = FactoryBot.create(:subscription, status: :active, last_charge_at: 2.weeks.ago)

      expect(subscription.should_charge?).to eq(false)
    end

    it "returns true if subscription is active and it's beyond subscription period" do
      subscription = FactoryBot.create(:subscription, status: :active, last_charge_at: Subscription::SUBSCRIPTION_PERIOD + 1.day, metadata: {failed_charge_count: Subscription::FAILED_CHARGE_COUNT_BEFORE_OVERDUE + 1})

      expect(subscription.should_charge?).to eq(true)
    end
  end

  describe ".charge!" do
    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }

    context "happy" do
      let(:user) { FactoryBot.create(:user) }

      it "charges subscription if last_charge_at is null" do
        stripe_customer = Stripe::Customer.create(source: stripe_helper.generate_card_token)
        user = FactoryBot.create(:user, stripe_id: stripe_customer.id)
        subscription = FactoryBot.create(:subscription_beyond_subscription_period, user: user, amount: 25)

        subscription.charge!

        subscription.reload
        donation = subscription.donations.last

        expect(subscription.donations.count).to eq(1)
        expect(donation.amount).to eq(subscription.amount)
        expect(subscription.last_charge_at.to_i).to be_within(100).of(DateTime.now.to_i)
      end

      it "charges subscription if it's beyond subscription period" do
        stripe_customer = Stripe::Customer.create(source: stripe_helper.generate_card_token)
        user = FactoryBot.create(:user, stripe_id: stripe_customer.id)
        subscription = FactoryBot.create(:subscription_beyond_subscription_period, user: user, amount: 25)

        expect(subscription.beyond_subscription_period?).to eq(true)

        subscription.charge!
        subscription.reload

        donation = subscription.donations.last

        expect(subscription.beyond_grace_period?).to eq(false)
        expect(subscription.donations.count).to eq(1)
        expect(donation.amount).to eq(subscription.amount)
        expect(subscription.last_charge_at.to_i).to be_within(100).of(DateTime.now.to_i)
      end
    end

    context "error" do
      let(:user) { FactoryBot.create(:user) }

      it "raises error if trying to charge a subscription before subscription period" do
        subscription = FactoryBot.create(:subscription_with_donation, user: user, amount: 25)

        expect(subscription.beyond_subscription_period?).to eq(false)

        expect { subscription.charge! }.to raise_error(SubscriptionNotOverdueError)
      end

      it "doesn't disable subscription if charge fails before grace period" do
        subscription = FactoryBot.create(:subscription_beyond_subscription_period, user: user, amount: 25)

        expect(subscription.active?).to eq(true)
        expect(subscription.beyond_subscription_period?).to eq(true)

        StripeMock.prepare_card_error(:card_declined)
        expect(MembershipMailer).to receive_message_chain(:payment_failure_email, :deliver_later)

        subscription.charge!
        subscription.reload

        expect(subscription.active?).to eq(true)
        expect(subscription.beyond_subscription_period?).to eq(true)
        expect(subscription.overdue?).to eq(false)
      end

      it "sets subscription to overdue if charge fails beyond grace period" do
        subscription = FactoryBot.create(:subscription_beyond_grace_period, user: user, amount: 25)

        expect(subscription.active?).to eq(true)
        expect(subscription.beyond_grace_period?).to eq(true)

        StripeMock.prepare_card_error(:card_declined)
        expect(MembershipMailer).to receive_message_chain(:payment_failure_email, :deliver_later)

        subscription.charge!
        subscription.reload

        expect(subscription.active?).to eq(false)
        expect(subscription.overdue?).to eq(true)
        expect(subscription.beyond_grace_period?).to eq(true)
      end
    end
  end
end
