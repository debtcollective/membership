# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChargesController, type: :controller do
  let!(:default_fund) { FactoryBot.create(:default_fund) }
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:valid_params) do
    {
      address_city: Faker::Address.city,
      address_country_code: Faker::Address.country_code,
      address_line1: Faker::Address.street_address,
      address_zip: Faker::Address.zip_code,
      amount: 12,
      customer_ip: "127.0.0.1",
      email: Faker::Internet.email,
      fund_id: 1,
      name: Faker::Name.name,
      phone_number: Faker::PhoneNumber.phone_number,
      stripe_token: stripe_helper.generate_card_token
    }
  end
  before { StripeMock.start }
  after { StripeMock.stop }

  describe "POST #create" do
    context "html" do
      it "creates a donation and sends the thank you email" do
        expect(DonationMailer).to receive_message_chain(:thank_you_email, :deliver_later)

        params = {charge: valid_params}
        expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

        expect(response).to redirect_to("/thank-you")
      end

      it "doesn't create Donation if a required field is missing" do
        user = FactoryBot.create(:user)

        params = {charge: {amount: 24, email: user.email, stripe_token: stripe_helper.generate_card_token, name: user.name}}
        expect { post :create, params: params, session: {} }.to change { Donation.count }.by(0)
      end

      it "Donation belongs to fund if fund_id is valid" do
        fund = FactoryBot.create(:fund)

        params = valid_params.merge({
          fund_id: fund.id
        })

        expect { post :create, params: {charge: params}, session: {} }.to change { Donation.count }.by(1)

        expect(Donation.last.fund).to eq(fund)
      end

      it "Donation belongs to default fund if fund_id is missing" do
        params = valid_params.merge({
          fund_id: nil
        })

        expect { post :create, params: {charge: params}, session: {} }.to change { Donation.count }.by(1)

        expect(Donation.last.fund).to eq(default_fund)
      end

      it "Donation belongs to default fund if fund_id is invalid" do
        fund_id = "invalid-id"

        params = valid_params.merge({
          fund_id: fund_id
        })

        expect { post :create, params: {charge: params}, session: {} }.to change { Donation.count }.by(1)

        expect(Donation.last.fund).to eq(default_fund)
      end
    end

    context "json" do
      before(:each) do
        request.accept = "application/json"
      end

      it "creates a donation and sends the thank you email" do
        expect(DonationMailer).to receive_message_chain(:thank_you_email, :deliver_later)

        params = {charge: valid_params.merge({amount: 23})}
        expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

        parsed_body = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(parsed_body["status"]).to eq("succeeded")
        expect(parsed_body["message"]).to eq("Your $23.00 donation has been successfully processed")
      end

      it "doesn't create Donation if a required field is missing" do
        user = FactoryBot.create(:user)

        params = {charge: {amount: 4, email: user.email, stripe_token: stripe_helper.generate_card_token, name: user.name}}
        expect { post :create, params: params, session: {} }.to change { Donation.count }.by(0)

        parsed_body = JSON.parse(response.body)
        expect(response).to have_http_status(422)
        expect(parsed_body["errors"]).not_to be_empty
        expect(parsed_body["errors"]["address_line1"]).to eq(["can't be blank"])
        expect(parsed_body["errors"]["amount"]).to eq(["must be greater than or equal to 5"])
      end

      it "creates a Subscription if donation_type is 'subscription'" do
        user = FactoryBot.create(:user)
        allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
        expect(DonationMailer).to receive_message_chain(:thank_you_email, :deliver_later)

        expect(User.count).to eq(1)

        params = {charge: valid_params.merge({amount: 23, donation_type: "subscription"})}
        expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

        expect(User.count).to eq(1)

        subscription = user.active_subscription

        parsed_body = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(parsed_body["status"]).to eq("succeeded")
        expect(parsed_body["message"]).to eq("Your $23.00 donation has been successfully processed")

        expect(subscription.active).to eq(true)
        expect(subscription.amount).to eq(23)
        expect(subscription.last_charge_at).to be_within(1.second).of DateTime.now
      end

      it "creates a User and a Subscription if donation_type is 'subscription'" do
        expect(DonationMailer).to receive_message_chain(:thank_you_email, :deliver_later)

        expect(User.count).to eq(0)

        params = {charge: valid_params.merge({email: "newuser@example.com", amount: 23, donation_type: "subscription"})}
        expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

        expect(User.count).to eq(1)

        user = User.find_by(email: "newuser@example.com")
        donation = user.donations.last
        subscription = user.active_subscription

        parsed_body = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(parsed_body["status"]).to eq("succeeded")
        expect(parsed_body["message"]).to eq("Your $23.00 donation has been successfully processed")

        expect(subscription.active).to eq(true)
        expect(subscription.amount).to eq(23)
        expect(subscription.last_charge_at).to be_within(2.second).of DateTime.now

        expect(donation.donation_type).to eq(Donation::DONATION_TYPES[:subscription])
        expect(donation.amount).to eq(23)
      end
    end
  end
end
