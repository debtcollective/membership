# frozen_string_literal: true

require "rails_helper"

RSpec.describe MembershipsController, type: :controller do
  describe "PATCH #update_amount" do
    it "with valid amount it updates the membership amount" do
      user = FactoryBot.create(:user_with_subscription, email: "example@debtcollective.org")
      subscription = user.active_subscription

      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      put :update_amount, params: {subscription: {amount: 10}}
      subscription.reload

      expect(response.status).to eq(302)
      expect(subscription.amount).to eq(10)
    end

    it "it returns an error with an amount less than 5 USD" do
      user = FactoryBot.create(:user_with_subscription, email: "example@debtcollective.org")
      subscription = user.active_subscription

      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      put :update_amount, params: {subscription: {amount: 4}}
      subscription.reload

      expect(response.status).to eq(200)
      expect(subscription.amount).not_to eq(4)
    end
  end

  describe "PUT #update_card" do
  end
end
