# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubscribeUserToNewsletterJob, type: :job do
  context "queue" do
    let(:user) { FactoryBot.create(:user) }
    subject(:job) { described_class.perform_later(user) }

    it "queues the job" do
      expect { job }
        .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it "is in default queue" do
      expect(SubscriptionPaymentJob.new.queue_name).to eq("default")
    end
  end

  describe "#perform" do
    context "happy" do
      let(:user) { FactoryBot.create(:user, email: "orlando@example.com", custom_fields: {phone_number: Faker::PhoneNumber.phone_number, customer_ip: "127.0.0.1"}) }

      it "subscribes user to the newsletter list" do
        # mock calls
        email_hash = Digest::MD5.hexdigest(user.email)
        stub_request(:put, "https://us8.api.mailchimp.com/3.0/lists/#{ENV["MAILCHIMP_LIST_ID"]}/members/#{email_hash}")
          .to_return(status: 200, body: "", headers: {})

        perform_enqueued_jobs { SubscribeUserToNewsletterJob.perform_later(user_id: user.id) }

        user.reload

        expect(user.id).to eq(user.id)
      end

      it "subscribes user with tags to the newsletter list" do
        # mock calls
        email_hash = Digest::MD5.hexdigest(user.email)
        stub_request(:put, "https://us8.api.mailchimp.com/3.0/lists/#{ENV["MAILCHIMP_LIST_ID"]}/members/#{email_hash}")
          .to_return(status: 200, body: "", headers: {})

        stub_request(:post, "https://us8.api.mailchimp.com/3.0/lists/#{ENV["MAILCHIMP_LIST_ID"]}/members/#{email_hash}/tags")
          .with(body: "{\"tags\":[{\"name\":\"member\",\"status\":\"active\"}]}")
          .to_return(status: 200, body: "", headers: {})

        perform_enqueued_jobs { SubscribeUserToNewsletterJob.perform_later(user_id: user.id, tags: [{name: "member", status: "active"}]) }

        user.reload

        expect(user.id).to eq(user.id)
      end
    end

    context "error" do
    end
  end

  around do |example|
    ClimateControl.modify(MAILCHIMP_API_KEY: "aa111111c11e000000e0b11d0d0a1111-us8", MAILCHIMP_LIST_ID: "ab12345ab6") do
      example.run
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
