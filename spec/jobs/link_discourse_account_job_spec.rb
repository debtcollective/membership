# frozen_string_literal: true

require "rails_helper"

RSpec.describe LinkDiscourseAccountJob, type: :job do
  it "queues the job" do
    expect { LinkDiscourseAccountJob.perform_later }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in default queue" do
    expect(LinkDiscourseAccountJob.new.queue_name).to eq("default")
  end

  describe "#perform" do
    let(:user) { FactoryBot.create(:user, external_id: nil) }

    it "it creates an invite if there's not a Discourse account" do
      # mocks
      expect_any_instance_of(DiscourseService).to receive(:find_user_by_email).and_return(nil)
      expect_any_instance_of(DiscourseService).to receive(:invite_user).and_return({"success" => "OK"})

      perform_enqueued_jobs { LinkDiscourseAccountJob.perform_later(user) }
    end

    it "it sets external_id to the once found on Discourse" do
      # mocks
      expect_any_instance_of(DiscourseService).to receive(:find_user_by_email).and_return({"id" => 10})
      expect_any_instance_of(DiscourseService).not_to receive(:invite_user)

      perform_enqueued_jobs { LinkDiscourseAccountJob.perform_later(user) }

      user.reload
      expect(user.external_id).to eq(10)
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
