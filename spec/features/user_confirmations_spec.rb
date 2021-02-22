# frozen_string_literal: true

require "rails_helper"

describe "UserConfirmations", type: :feature do
  context "with valid token" do
    it "validates user after completing flow" do
      user = FactoryBot.create(:user, confirmation_token: "token")

      visit "/user_confirmations?confirmation_token=#{user.confirmation_token}"

      click_button "Confirm my email"

      user.reload
      expect(user.confirmed_at.to_i).to be_within(100).of(DateTime.now.to_i)
    end
  end

  context "with invalid token" do
    it "shows invalid token error" do
      FactoryBot.create(:user)

      visit "/user_confirmations?confirmation_token=invalid"

      expect(page).to have_content("Invalid confirmation token")
    end
  end

  context "alredy validated user" do
    it "shows already confirmed error" do
      user = FactoryBot.create(:user, confirmation_token: "token", confirmed_at: DateTime.now)

      visit "/user_confirmations?confirmation_token=#{user.confirmation_token}"

      expect(page).to have_content("Your email has been already confirmed")
      expect(page).to have_content("Click here to go to the login page")
    end
  end
end
