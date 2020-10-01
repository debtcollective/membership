# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "GET #current" do
    before(:each) do
      request.accept = "application/json"
    end

    it "returns 404 if no user authenticated" do
      get :current

      expect(response.status).to eq(404)
      expect(response.body).to eq("null")
    end

    it "returns user if authenticated" do
      user = FactoryBot.create(:user)
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      binding.pry

      get :current
      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json["id"]).to eq(user.id)
      expect(json["subscription"]).to eq(nil)
    end

    it "returns active membership if available" do
      user = FactoryBot.create(:user_with_subscription)
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      get :current
      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json["id"]).to eq(user.id)
      expect(json["subscription"]["id"]).to eq(user.active_subscription.id)
    end
  end
end
