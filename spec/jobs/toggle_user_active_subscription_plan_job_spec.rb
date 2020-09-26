# frozen_string_literal: true

require "rails_helper"

RSpec.describe ToggleUserActiveSubscriptionPlanJob, type: :job do
  let(:old_plan) { FactoryBot.create(:plan) }
  let(:new_plan) { FactoryBot.create(:plan) }
  let!(:user) { FactoryBot.create(:user) }
  let!(:active_subscription) { FactoryBot.create(:subscription, user: user, plan: old_plan) }

  it "queues the job" do
    plan_change = FactoryBot.create(:user_plan_change, user: user, old_plan_id: old_plan.id, new_plan_id: new_plan.id, status: "pending")

    expect { ToggleUserActiveSubscriptionPlanJob.perform_later(plan_change) }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in default queue" do
    expect(ToggleUserActiveSubscriptionPlanJob.new.queue_name).to eq("default")
  end

  it "executes perform" do
    plan_change = FactoryBot.create(:user_plan_change, user: user, old_plan_id: old_plan.id, new_plan_id: new_plan.id, status: "pending")

    expect(Subscription.count).to eq(1)
    expect(user.active_subscription.plan.id).to eq(old_plan.id)

    perform_enqueued_jobs { ToggleUserActiveSubscriptionPlanJob.perform_later(plan_change) }

    expect(Subscription.count).to eq(2)
    user_id = user.id
    user = User.find(user_id)
    plan_change.reload

    expect(user.active_subscription.plan.id).to eq(new_plan.id)
    expect(plan_change.status).to eq("succeeded")
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
