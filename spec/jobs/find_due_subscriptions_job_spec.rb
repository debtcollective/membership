# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindDueSubscriptionsJob, type: :job do
  let!(:recently_paid_active_subscription) { FactoryBot.create(:subscription, status: :active, last_charge_at: 2.weeks.ago) }
  let!(:inactive_subscription) { FactoryBot.create(:subscription, status: :inactive) }
  let!(:due_subscription_one) { FactoryBot.create(:subscription, status: :active, last_charge_at: (Subscription::SUBSCRIPTION_PERIOD + 1.day).ago) }
  let!(:due_subscription_two) { FactoryBot.create(:subscription, status: :active, last_charge_at: nil) }
  let!(:free_subscription) { FactoryBot.create(:subscription, amount: 0, status: :active, last_charge_at: nil) }

  it "queues the job" do
    expect { FindDueSubscriptionsJob.perform_later }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in default queue" do
    expect(FindDueSubscriptionsJob.new.queue_name).to eq("default")
  end

  it "executes perform" do
    expect { FindDueSubscriptionsJob.perform_now }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(2)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
