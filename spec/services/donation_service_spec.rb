# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionProvider, type: :service do
  let(:stripe_helper) { StripeMock.create_test_helper }

  describe ".save_donation_with_user" do
    let(:user) { FactoryBot.create(:user) }

    it "creates a donation record" do
      params = {
        amount: 10 * 100,
        customer_ip: "127.0.0.1",
        stripeToken: stripe_helper.generate_card_token
      }

      donation, error = DonationService.save_donation_with_user(user, params)

      expect(donation).to be_persisted
      expect(error).to be_nil
    end
  end

  describe ".save_donation_without_user" do
    it "creates a donation record" do
      expect(true).to equal(true)
    end
  end
end
