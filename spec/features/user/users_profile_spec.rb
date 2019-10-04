# frozen_string_literal: true

require 'rails_helper'

describe 'User - manages their profile', type: :feature, js: true do
  describe 'home' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:subscription) { FactoryBot.create(:subscription, user_id: user.id) }
    let!(:one_time_donations) { FactoryBot.create_list(:donation, 5, user_id: user.id, donation_type: Donation::DONATION_TYPES[:one_off]) }

    before(:each) do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
    end

    it 'can view their subscription and donation history' do
      5.times do
        donation = FactoryBot.create(:donation, user_id: user.id)
        FactoryBot.create(:subscription_donation, subscription_id: subscription.id, donation_id: donation.id)
      end
      visit user_path(user)
      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)

      expect(page).to have_content(subscription.plan.name)

      user.donations.each do |donation|
        expect(page).to have_content(donation.amount)
      end
    end
  end
end
