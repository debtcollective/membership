# frozen_string_literal: true

require 'rails_helper'

describe 'Subscriptions', type: :feature do
  context 'without a user account' do
    let!(:plan) { FactoryBot.create(:plan) }
    let(:new_user) { FactoryBot.attributes_for(:user) }

    it 'allows going through the flow and prompts for a user account creation' do
      visit '/'
      expect(page).to have_content('Welcome to app!')
      expect(page).to have_content(plan.name)

      within "#subscription-#{plan.name.parameterize.underscore}" do
        click_link 'Subscribe'
      end

      expect(page).to have_content(plan.name)

      click_button 'Start Donating'

      expect(page).to have_content('Please create an account')

      # create account
      fill_in 'First name', with: new_user[:first_name]
      fill_in 'Last name', with: new_user[:last_name]
      fill_in 'Email', with: new_user[:email]

      click_button 'Continue'

      # payment details
      expect(page).to have_content('Payment')

      # TODO: Add Stripe elements

      click_link 'Finish'

      expect(page).to have_content('Subscription was successfully added.')
    end
  end
end
