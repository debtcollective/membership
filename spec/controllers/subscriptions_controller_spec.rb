# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubscriptionsController, type: :controller do
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:valid_params) do
    {
      address_city: Faker::Address.city,
      address_country_code: Faker::Address.country_code,
      address_line1: Faker::Address.street_address,
      address_zip: Faker::Address.zip_code,
      amount: 20,
      email: Faker::Internet.email,
      name: Faker::Name.name,
      phone_number: Faker::PhoneNumber.phone_number,
      stripe_token: stripe_helper.generate_card_token
    }
  end
  before { StripeMock.start }
  after { StripeMock.stop }

  describe "POST #create" do
    before(:each) do
      request.accept = "application/json"
    end

    it "creates a membership and sends the welcome email" do
      expect(UserMailer).to receive_message_chain(:welcome_email, :deliver_later)

      params = {subscription: valid_params.merge({amount: 23})}
      expect { post :create, params: params, session: {} }.to change { Subscription.count }.by(1)

      user = User.last
      subscription = user.active_subscription

      expect(subscription.active).to eq(true)
      expect(subscription.amount).to eq(23)
      expect(subscription.last_charge_at).to be_within(1.second).of DateTime.now

      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(parsed_body["status"]).to eq("succeeded")
      expect(parsed_body["message"]).to eq("Thank you starting your membership.")
    end

    it "doesn't create a Membership if a required field is missing" do
      user = FactoryBot.create(:user)

      params = {subscription: {amount: 4, email: user.email, stripe_token: stripe_helper.generate_card_token, name: user.name}}
      expect { post :create, params: params, session: {} }.to change { Subscription.count }.by(0)

      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(422)
      expect(parsed_body["errors"]).not_to be_empty
      expect(parsed_body["errors"]["address_line1"]).to eq(["can't be blank"])
      expect(parsed_body["errors"]["amount"]).to eq(["must be greater than or equal to 5"])
    end

    it "creates a User and a Subscription if there's no current_user" do
      expect(UserMailer).to receive_message_chain(:welcome_email, :deliver_later)

      expect(User.count).to eq(0)

      params = {subscription: valid_params.merge({email: "newuser@example.com", amount: 23})}
      expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

      expect(User.count).to eq(1)

      user = User.find_by(email: "newuser@example.com")
      donation = user.donations.last
      subscription = user.active_subscription

      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(parsed_body["status"]).to eq("succeeded")
      expect(parsed_body["message"]).to eq("Thank you starting your membership.")

      expect(subscription.active).to eq(true)
      expect(subscription.amount).to eq(23)
      expect(subscription.last_charge_at).to be_within(2.second).of DateTime.now

      expect(donation.donation_type).to eq(Donation::DONATION_TYPES[:subscription])
      expect(donation.amount).to eq(23)
    end

    it "returns an error if a user by the email provided has already a subscription" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:subscription, user: user)

      params = {subscription: valid_params.merge({email: user.email, amount: 16})}
      expect { post :create, params: params, session: {} }.to change { Donation.count }.by(0)

      parsed_body = JSON.parse(response.body)
      expect(response).to have_http_status(422)
      expect(parsed_body["status"]).to eq("failed")
      expect(parsed_body["message"]).to eq(I18n.t("subscription.errors.active_subscription"))
    end
  end
end
