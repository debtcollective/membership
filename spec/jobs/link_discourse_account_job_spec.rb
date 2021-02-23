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
    context "existing account" do
      it "it sets external_id to the one found on Discourse if user is confirmed" do
        user = FactoryBot.create(:user, external_id: nil, confirmed_at: DateTime.now)

        expect_any_instance_of(DiscourseService).to receive(:find_user_by_email).and_return({"id" => 10})
        expect_any_instance_of(DiscourseService).not_to receive(:invite_user)

        perform_enqueued_jobs { LinkDiscourseAccountJob.perform_later(user) }

        user.reload
        expect(user.external_id).to eq(10)
      end

      it "it send confirmation email if user is on Discourse but not confirmed" do
        user = FactoryBot.create(:user, external_id: nil)

        expect_any_instance_of(DiscourseService).to receive(:find_user_by_email).and_return({"id" => 10})
        expect_any_instance_of(DiscourseService).not_to receive(:invite_user)
        expect(UserMailer).to receive_message_chain(:confirmation_email, :deliver_later)

        perform_enqueued_jobs { LinkDiscourseAccountJob.perform_later(user) }

        user.reload
        expect(user.external_id).to be_nil
      end
    end

    context "new account" do
      it "creates a discourse account and updates the user record" do
        user = FactoryBot.create(:user, external_id: nil)
        response = {
          "success" => true,
          "active" => true,
          "email_token" => "15fa6c1c626cb97ccf18e5abd537260e",
          "message" =>
            "Your account is activated and ready to use.",
          "user_id" => 9,
          "username" => "orlando"
        }

        expect_any_instance_of(DiscourseService).to receive(:find_user_by_email).and_return(nil)
        expect_any_instance_of(DiscourseService).to receive(:create_user).and_return(response)
        expect(UserMailer).to receive_message_chain(:welcome_email, :deliver_later)

        perform_enqueued_jobs { LinkDiscourseAccountJob.perform_later(user) }
        user.reload

        expect(user.external_id).to eq(9)
        expect(user.username).to eq("orlando")
        expect(user.email_token).to be_present
      end
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
