# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangeSubscriptionPlansJob, type: :job do
  let(:user) { FactoryBot.create(:user) }
  let!(:old_plan) { FactoryBot.create(:plan) }
  let!(:new_plan) { FactoryBot.create(:plan) }
  let!(:active_subscription) { FactoryBot.create(:subscription, user: user, plan: old_plan) }
  let!(:plan_change) { FactoryBot.create(:user_plan_change, user: user, old_plan_id: old_plan.id, new_plan_id: new_plan.id, status: 'pending') }

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(ChangeSubscriptionPlansJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect do
      described_class.perform_now
    end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
