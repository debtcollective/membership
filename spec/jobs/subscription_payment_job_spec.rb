# frozen_string_literal: true

require "rails_helper"
require "stripe_mock"

RSpec.describe SubscriptionPaymentJob, type: :job do
  let!(:subscription) { FactoryBot.create(:subscription) }
  let(:user) { subscription.user }
  let(:plan) { subscription.plan }
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  subject(:job) { described_class.perform_later(subscription) }

  it "queues the job" do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in default queue" do
    expect(SubscriptionPaymentJob.new.queue_name).to eq("default")
  end

  describe "#perform" do
    it "charges correctly if customer has a valid card" do
      _really_old_donation = FactoryBot.create(:donation, user: user, amount: plan.amount, donation_type: Donation::DONATION_TYPES[:subscription], created_at: 5.months.ago)
      _old_donation = FactoryBot.create(:donation, user: user, amount: plan.amount, donation_type: Donation::DONATION_TYPES[:subscription], created_at: 1.month.ago)

      expect(Donation.count).to eq(2)

      perform_enqueued_jobs { job }

      expect(Donation.count).to eq(3)
      expect(subscription.reload.last_charge_at.to_i).to be_within(100).of(DateTime.now.to_i)
    end

    it "charges subscription.amount instead of plan.amount if plan is missing" do
      user = FactoryBot.create(:user)
      subscription = FactoryBot.create(:subscription, plan: nil, user: user, amount: 12, last_charge_at: 31.days.ago)

      expect(user.donations.count).to eq(0)

      perform_enqueued_jobs { SubscriptionPaymentJob.perform_later(subscription) }

      expect(user.donations.count).to eq(1)
      expect(user.donations.first.amount).to eq(subscription.amount)
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
