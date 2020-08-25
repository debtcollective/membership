# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChargesController, type: :controller do
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
  end
end
