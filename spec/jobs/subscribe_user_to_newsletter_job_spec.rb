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

  describe "#perform", vcr: {record: :once} do
    context "happy" do
      let(:user) {
        FactoryBot.create(:user,
          email: "no-reply@debtcollective.org",
          name: "Orlando Del Aguila",
          custom_fields: {
            phone_number: "+1 (603) 337-6816",
            customer_ip: "127.0.0.1",
            address_city: "Canton",
            address_state: "New York",
            address_country_code: "US",
            address_line1: "PO Box 593",
            address_zip: "13617-9998"
          })
      }

      it "subscribes user to the newsletter list" do
        SubscribeUserToNewsletterJob.perform_now(user_id: user.id)

        user.reload
        expect(user.custom_fields["subscribed_to_newsletter"]).to eq(true)
      end

      it "subscribes user with tags to the newsletter list" do
        SubscribeUserToNewsletterJob.perform_now(user_id: user.id, tags: [{name: "member", status: "active"}])

        user.reload
        expect(user.custom_fields["subscribed_to_newsletter"]).to eq(true)
      end
    end
  end

  around do |example|
    ClimateControl.modify(
      MAILCHIMP_API_KEY: "aa111111c11e000000e0b11d0d0a1111-us20",
      MAILCHIMP_LIST_ID: "ab12345ab6"
    ) do
      example.run
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
