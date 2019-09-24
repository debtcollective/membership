# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindOverdueSubscriptionsJob, type: :job do
  let!(:recently_paid_active_subscription) { FactoryBot.create(:subscription) }
  let!(:inactive_subscription) { FactoryBot.create(:subscription, active: false) }
  let!(:active_subscription_one) { FactoryBot.create(:subscription) }
  let!(:active_subscription_two) { FactoryBot.create(:subscription) }
  let!(:last_donation_of_recently_paid_subscription) { FactoryBot.create(:donation, user_id: recently_paid_active_subscription.user.id, amount: recently_paid_active_subscription.plan.amount, created_at: 2.weeks.ago) }
  let!(:last_donation_of_active_subscription_two) { FactoryBot.create(:donation, user_id: active_subscription_two.user.id, amount: active_subscription_two.plan.amount, created_at: 1.month.ago) }

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(FindOverdueSubscriptionsJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect do
      perform_enqueued_jobs { job }
    end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
