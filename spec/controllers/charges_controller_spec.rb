# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChargesController, type: :controller do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe "POST #create" do
    it "creates a donation and send an email" do
      user = FactoryBot.create(:user)

      expect(DonationMailer).to receive_message_chain(:thank_you_email, :deliver_later)

      params = {donation: {amount: 24}, stripeEmail: user.email, stripeToken: stripe_helper.generate_card_token}
      expect { post :create, params: params, session: {} }.to change { Donation.count }.by(1)

      expect(response).to redirect_to("/thank-you")
    end
  end
end
