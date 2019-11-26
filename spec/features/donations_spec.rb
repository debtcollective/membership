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

      click_link 'one-time-donation'

      expect(page).to have_content('Pay what you can. Every dollar counts.')

      within '.one-time-donation' do
        fill_stripe_elements(card: '4242424242424242')
        fill_in 'donation_amount', with: 25
        click_button 'Make my donation'
      end

      using_wait_time(10) do
        expect(page).to have_content('Thank you for donating $25.00')
      end
    end
  end

  context 'as anonymous', js: true do
    it 'allows going through the flow and prompts for a user account creation' do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(nil)
      visit '/'
      expect(page).to have_content('Log In') # checking user is logged in
      expect(page).to have_content('Pay what you can')

      click_link 'one-time-donation'

      expect(page).to have_content('Pay what you can. Every dollar counts.')

      within '.one-time-donation' do
        fill_stripe_elements(card: '4242424242424242')
        fill_in 'donation_amount', with: 25
        click_button 'Make my donation'
      end

      using_wait_time(10) do
        expect(page).to have_content('Thank you for donating $25.00')
      end
    end
  end
end
