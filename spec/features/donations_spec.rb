# frozen_string_literal: true

require 'rails_helper'

describe 'Donations', type: :feature do
  context 'as user', js: true do
    let!(:user) { FactoryBot.create(:user, stripe_id: nil) }

    it 'allows going through the flow and prompts for a user account creation' do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
      visit '/'
      expect(page).to_not have_content('Log In') # checking user is logged in
      expect(page).to have_content('Pay what you can')

      click_link 'Make a donation today'

      expect(page).to have_content('Pay what you can. Every dollar counts.')

      within '.one-time-donation' do
        fill_in 'donation-amount', with: 25
        click_button 'Pay with Card'
        # can't access elements inside iframe within capybara
      end
    end
  end
end
