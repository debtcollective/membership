# frozen_string_literal: true

require 'rails_helper'

describe 'Subscriptions', type: :feature do
  context 'without a user account' do
    let!(:plan) { FactoryBot.create(:plan) }
    let(:new_user) { FactoryBot.attributes_for(:user) }

    xit 'allows going through the flow and prompts for a user account creation' do
      visit '/'
      expect(page).to have_content('Every membership brings us closer to our goals.')
      expect(page).to have_content(plan.name)

      within "#subscription-#{plan.name.parameterize.underscore}" do
        click_link 'Subscribe'
      end

      expect(page).to have_content('Please create an account')

      # create account
      fill_in 'Name', with: new_user[:name]
      fill_in 'Email', with: new_user[:email]

      click_button 'Continue'

      # payment details
      expect(page).to have_content('Payment')

      # TODO: Add Stripe elements
    end
  end
end
