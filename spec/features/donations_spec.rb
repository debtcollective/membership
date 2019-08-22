# frozen_string_literal: true

require 'rails_helper'

describe 'Donations', type: :feature do
  context 'as an anonymous user' do
    it 'allows going through the flow and prompts for a user account creation' do
      visit '/'
      expect(page).to have_content('Welcome to app!')

      click_link 'Make a donation today'

      expect(page).to have_content('Donate today')

      within '#one-time-donation' do
        fill_in 'donation-amount', with: 25
        # TODO: add stripe elements expectations
        # click_button 'Pay with Card'
      end

      # expect(page).to have_content('Subscription was successfully added.')
    end
  end
end
