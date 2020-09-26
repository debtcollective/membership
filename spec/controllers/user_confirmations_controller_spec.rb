# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserConfirmationsController, type: :controller do
  describe "GET #index" do
    it "returns a success response if token is found" do
      user = FactoryBot.create(:user_with_confirmation_token)

      get :index, params: {confirmation_token: user.confirmation_token}

      expect(response.status).to eq(200)
    end

    it "returns not found if token is invalid" do
      get :index, params: {confirmation_token: SecureRandom.hex(20)}

      expect(response.status).to eq(404)
    end
  end

  describe "POST #create" do
    # This endpoint only supports json
    before(:each) do
      request.accept = "application/json"
    end

    it "creates and send user confirmation instructions" do
      user = FactoryBot.create(:user)

      expect(UserMailer).to receive_message_chain(:confirmation_email, :deliver_later)

      post :create, params: {email: user.email}

      expect(response.status).to eq(200)
    end

    it "returns not found if token is invalid" do
      post :create, params: {email: Faker::Internet.email}

      expect(response.status).to eq(404)
    end
  end

  describe "POST #confirm" do
    it "confirms user email if token is valid" do
      user = FactoryBot.create(:user_with_confirmation_token)

      post :confirm, params: {user_confirmation: {confirmation_token: user.confirmation_token}}
      user.reload

      expect(response.status).to eq(200)
      expect(user.confirmed_at).to be_within(1.second).of DateTime.now
      expect(user.confirmed?).to eq(true)
    end

    it "returns not found if token is invalid" do
      post :confirm, params: {user_confirmation: {confirmation_token: SecureRandom.hex(20)}}

      expect(response.status).to eq(404)
    end
  end
end
