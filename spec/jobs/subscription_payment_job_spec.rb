# frozen_string_literal: true

require 'rails_helper'
require 'stripe_mock'

def create_fake_stripe_customer(user)
  Stripe::Customer.create(
    email: user.email,
    source: 'tok_mastercard'
  )
end

RSpec.describe SubscriptionPaymentJob, type: :job do
  let!(:subscription) { FactoryBot.create(:subscription) }
  let(:user) { subscription.user }
  let(:plan) { subscription.plan }

  subject(:job) { described_class.perform_later(user: user, plan: plan) }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(SubscriptionPaymentJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    allow(Stripe::Customer).to receive(:retrieve).and_return(create_fake_stripe_customer(user))

    _really_old_donation = FactoryBot.create(:donation, user_id: user.id, amount: plan.amount, donation_type: Donation::DONATION_TYPES[:subscription], created_at: 5.months.ago)
    _old_donation = FactoryBot.create(:donation, user_id: user.id, amount: plan.amount, donation_type: Donation::DONATION_TYPES[:subscription], created_at: 1.month.ago)

    expect(Donation.count).to eq(2)

    perform_enqueued_jobs { job }

    expect(Donation.count).to eq(3)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
