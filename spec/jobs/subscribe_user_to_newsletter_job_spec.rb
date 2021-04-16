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
      expect(described_class.new.queue_name).to eq("mailers")
    end
  end

  describe "#perform" do
    context "happy", vcr: {record: :once} do
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

    context "error" do
      it "retries the job if the user doesn't have the state in their profile" do
        user = FactoryBot.create(:user,
          email: "no-reply@debtcollective.org",
          name: "Orlando Del Aguila",
          custom_fields: {
            phone_number: "+16033376816",
            customer_ip: "127.0.0.1",
            address_city: "Canton",
            address_country_code: "US",
            address_line1: "PO Box 593",
            address_zip: "13617-9998"
          })

        stub_request(:put, "https://us20.api.mailchimp.com/3.0/lists/ab12345ab6/members/cc580437dcf8d2ad667ccb8f4b416252")
          .with(
            body: "{\"email_address\":\"no-reply@debtcollective.org\",\"status\":\"subscribed\",\"ip_signup\":\"127.0.0.1\",\"merge_fields\":{\"FNAME\":\"Orlando\",\"LNAME\":\"Del Aguila\",\"PHONE\":\"+16033376816\"}}",
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "Authorization" => "Basic YXBpa2V5OmFhMTExMTExYzExZTAwMDAwMGUwYjExZDBkMGExMTExLXVzMjA=",
              "Content-Type" => "application/json",
              "User-Agent" => "Faraday v1.3.0"
            }
          )
          .to_return(status: 200, body: "", headers: {})

        assert_performed_jobs 2 do
          SubscribeUserToNewsletterJob.perform_later(user_id: user.id)
        end
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
