# frozen_string_literal: true

require "rails_helper"

RSpec.describe ToggleUserActiveSubscriptionPlanJob do
  let(:user) { FactoryBot.create(:user) }
  let!(:old_plan) { FactoryBot.create(:plan) }
  let!(:new_plan) { FactoryBot.create(:plan) }
  let!(:active_subscription) { FactoryBot.create(:subscription, user: user, plan: old_plan) }
  let!(:plan_change) { FactoryBot.create(:user_plan_change, user: user, old_plan_id: old_plan.id, new_plan_id: new_plan.id, status: "pending") }

  subject(:job) { described_class.perform_later(plan_change) }

  it "queues the job" do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in default queue" do
    expect(ToggleUserActiveSubscriptionPlanJob.new.queue_name).to eq("default")
  end

  it "executes perform" do
    expect(Subscription.count).to eq(1)
    expect(user.active_subscription.plan.id).to eq(old_plan.id)

    perform_enqueued_jobs { job }

    expect(Subscription.count).to eq(2)
    user.active_subscription.reload
    expect(user.active_subscription.plan.id).to eq(new_plan.id)
    expect(plan_change.reload.status).to eq("succeeded")
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
