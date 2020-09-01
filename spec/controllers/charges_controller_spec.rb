# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChargesController, type: :controller do
  let!(:default_fund) { FactoryBot.create(:fund, slug: Fund::DEFAULT_SLUG) }
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe "POST #create" do
    it "creates a donation and sends the thank you email" do
      user = FactoryBot.create(:user)

      expect(DonationMailer).to receive_message_chain(:thank_you_email, :deliver_later)

      params = {charge: {amount: 24, email: user.email, stripe_token: stripe_helper.generate_card_token, name: user.name, phone_number: Faker::PhoneNumber.phone_number}}
      expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

      expect(response).to redirect_to("/thank-you")
    end

    it "doesn't create Donation if a personal info field is missing" do
      user = FactoryBot.create(:user)

      params = {charge: {amount: 24, email: user.email, stripe_token: stripe_helper.generate_card_token, name: user.name}}
      expect { post :create, params: params, session: {} }.to change { Donation.count }.by(0)
    end

    it "Donation belongs to fund if fund_id is valid" do
      user = FactoryBot.create(:user)
      fund = FactoryBot.create(:fund)

      params = {
        charge: {
          amount: 24,
          email: user.email,
          stripe_token: stripe_helper.generate_card_token,
          name: user.name,
          phone_number: Faker::PhoneNumber.phone_number,
          fund_id: fund.id
        }
      }

      expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

      expect(Donation.last.fund).to eq(fund)
    end

    it "Donation belongs to default fund if fund_id is missing" do
      user = FactoryBot.create(:user)

      params = {
        charge: {
          amount: 24,
          email: user.email,
          stripe_token: stripe_helper.generate_card_token,
          name: user.name,
          phone_number: Faker::PhoneNumber.phone_number
        }
      }
      expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

      expect(Donation.last.fund).to eq(default_fund)
    end

    it "Donation belongs to default fund if fund_id is invalid" do
      user = FactoryBot.create(:user)
      fund_id = "invalid-id"

      params = {
        charge: {
          amount: 24,
          email: user.email,
          stripe_token: stripe_helper.generate_card_token,
          name: user.name,
          phone_number: Faker::PhoneNumber.phone_number,
          fund_id: fund_id
        }
      }
      expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

      expect(Donation.last.fund).to eq(default_fund)
    end
  end
end
