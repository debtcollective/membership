# frozen_string_literal: true

require "rails_helper"

RSpec.describe DonationService, type: :service do
  let(:stripe_helper) { StripeMock.create_test_helper }

  describe ".save_donation_with_user" do
    let(:user) { FactoryBot.create(:user) }

    it "creates a donation record" do
      params = {
        amount: 10_000, # 10 USD
        customer_ip: "127.0.0.1",
        stripeToken: stripe_helper.generate_card_token
      }

      donation, error = DonationService.save_donation_with_user(user, params)

      expect(donation).to be_persisted
      expect(donation.user_data["email"]).to eq(user.email)
      expect(donation.amount).to eq(10_000)
      expect(donation.charge_data).to have_key("id")
      expect(donation.status).to eq("succeeded")
      expect(error).to be_nil
    end

    it "returns error if invalid stripe token" do
      params = {
        amount: 10_000,
        customer_ip: "127.0.0.1",
        stripeToken: Faker::Internet.uuid
      }

      donation, error = DonationService.save_donation_with_user(user, params)

      expect(donation).to be_nil
      expect(error).to be_truthy
    end
  end

  describe ".save_donation_without_user" do
    it "creates a donation record" do
      params = {
        amount: 10_000,
        stripeEmail: Faker::Internet.email,
        stripeToken: stripe_helper.generate_card_token,
        customer_ip: "127.0.0.1"
      }

      donation, error = DonationService.save_donation_without_user(params)

      expect(donation).to be_persisted
      expect(donation.user_data["email"]).to eq(params[:stripeEmail])
      expect(donation.amount).to eq(10_000)
      expect(donation.charge_data).to have_key("id")
      expect(donation.status).to eq("succeeded")
      expect(error).to be_nil
    end
  end
end
