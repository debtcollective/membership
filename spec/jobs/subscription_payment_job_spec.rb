# frozen_string_literal: true

require "rails_helper"
require "stripe_mock"

RSpec.describe SubscriptionPaymentJob, type: :job do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  context "queue" do
    let(:subscription) { FactoryBot.create(:subscription) }
    subject(:job) { described_class.perform_later(subscription) }

    it "queues the job" do
      expect { job }
        .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it "is in default queue" do
      expect(SubscriptionPaymentJob.new.queue_name).to eq("default")
    end
  end

  describe "#perform" do
    context "happy" do
      let(:user) { FactoryBot.create(:user) }

      it "charges subscription if last_charge_at is null" do
        stripe_customer = Stripe::Customer.create(source: stripe_helper.generate_card_token)
        user = FactoryBot.create(:user, stripe_id: stripe_customer.id)
        subscription = FactoryBot.create(:subscription_beyond_subscription_period, user: user, amount: 25)

        perform_enqueued_jobs { SubscriptionPaymentJob.perform_later(subscription) }

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

        perform_enqueued_jobs { SubscriptionPaymentJob.perform_later(subscription) }

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

        expect { SubscriptionPaymentJob.perform_now(subscription) }.to raise_error(SubscriptionNotOverdueError)
      end

      it "doesn't disable subscription if charge fails before grace period" do
        subscription = FactoryBot.create(:subscription_beyond_subscription_period, user: user, amount: 25)

        expect(subscription.active?).to eq(true)
        expect(subscription.beyond_subscription_period?).to eq(true)

        StripeMock.prepare_card_error(:card_declined)

        perform_enqueued_jobs { SubscriptionPaymentJob.perform_later(subscription) }
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

        perform_enqueued_jobs { SubscriptionPaymentJob.perform_later(subscription) }
        subscription.reload

        expect(subscription.active?).to eq(false)
        expect(subscription.overdue?).to eq(true)
        expect(subscription.beyond_grace_period?).to eq(true)
      end
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
