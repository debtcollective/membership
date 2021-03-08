# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserConfirmationsController, type: :controller do
  describe "GET #confirm_email_token" do
    render_views

    it "renders view to confirm user account if token is valid" do
      user = FactoryBot.create(:user, email_token: SecureRandom.hex(20))

      get :confirm_email_token, params: {email_token: user.email_token}
      user.reload

      expect(response.status).to eq(200)
      expect(response.body).to include("Confirm my email")
      expect(user.confirmed?).to eq(false)
    end

    it "returns not found if token is invalid" do
      expect { get :confirm_email_token, params: {email_token: SecureRandom.hex(20)} }.to raise_error(ActionController::RoutingError)
    end
  end

  describe "POST #confirm_email" do
    it "confirms user email if email token is valid" do
      user = FactoryBot.create(:user_with_email_token)

      post :confirm_email, params: {user_confirmation: {email_token: user.email_token}}
      user.reload

      expect(response.status).to eq(302)
      expect(user.confirmed?).to eq(true)
      expect(user.confirmed_at).to be_within(1.second).of DateTime.now
    end

    it "returns not found if token is invalid" do
      expect {
        post :confirm_email, params: {user_confirmation: {email_token: SecureRandom.hex(20)}}
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
