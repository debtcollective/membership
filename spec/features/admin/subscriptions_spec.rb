# frozen_string_literal: true

require "rails_helper"

describe "Admin - Manages user subscriptions", type: :feature, js: true do
  let!(:admin) { FactoryBot.create(:user, admin: true) }

  before(:each) do
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(admin)
  end

  describe "home" do
    let!(:subscription_1) { FactoryBot.create(:subscription) }
    let!(:subscription_2) { FactoryBot.create(:subscription) }

    it "presents a list of subscriptions" do
      visit "/admin/subscriptions"
      expect(page).to have_content("Subscriptions")

      expect(page).to have_content(subscription_1.user.name)
      expect(page).to have_content(subscription_1.amount)

      expect(page).to have_content(subscription_2.user.name)
      expect(page).to have_content(subscription_2.amount)
    end
  end

  describe "subscriptions details" do
    let!(:subscription) { FactoryBot.create(:subscription) }

    it "contains related donations" do
      subscription_donations = FactoryBot.create_list(:subscription_donation, 5, subscription_id: subscription.id)

      visit "/admin/subscriptions"
      expect(page).to have_content("Subscriptions")

      expect(page).to have_content(subscription.user.name)
      click_link("Show", href: admin_subscription_path(subscription))

      subscription_donations.each do |subscription_donation|
        donation = subscription_donation.donation
        within "#donation-#{donation.id}" do
          expect(page).to have_content(donation.amount)
          expect(page).to have_content(donation.customer_stripe_id)
        end
      end
    end
  end
end
