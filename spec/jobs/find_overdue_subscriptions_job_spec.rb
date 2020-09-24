# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindOverdueSubscriptionsJob, type: :job do
  let!(:recently_paid_active_subscription) { FactoryBot.create(:subscription, last_charge_at: 2.weeks.ago) }
  let!(:inactive_subscription) { FactoryBot.create(:subscription, active: false) }
  let!(:active_subscription_one) { FactoryBot.create(:subscription, last_charge_at: 32.days.ago) }
  let!(:active_subscription_two) { FactoryBot.create(:subscription, last_charge_at: nil) }
  let!(:active_subscription_zero_amount) { FactoryBot.create(:subscription, amount: 0, last_charge_at: nil) }

  it 'queues the job' do
    expect { FindOverdueSubscriptionsJob.perform_later }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(FindOverdueSubscriptionsJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect { FindOverdueSubscriptionsJob.perform_now }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
