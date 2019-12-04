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

  context 'with a logged in user', js: true do
    let!(:plan) { FactoryBot.create(:plan, amount: 10.0) }
    let(:user) { FactoryBot.create(:user, stripe_id: nil) }

    it('can start a subscription') do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
      visit '/'
      expect(page).to_not have_content('Log In') # checking user is logged in
      expect(page).to have_content(plan.name)

      click_link "subscription-#{plan.name.parameterize.underscore}"

      expect(page).to have_content(plan.name)
      expect(page).to have_content(plan.description)
      expect(page).to have_content('Credit or debit card')
      fill_stripe_elements(card: '4242424242424242')

      click_button('Enroll Membership for $10/mo')
      using_wait_time(10) do
        expect(page).to have_content('Thank you for subscribing')
      end
    end

    it 'notifies when the transaction was declined' do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
      visit '/'
      expect(page).to_not have_content('Log In') # checking user is logged in
      expect(page).to have_content(plan.name)

      click_link "subscription-#{plan.name.parameterize.underscore}"

      expect(page).to have_content(plan.name)
      expect(page).to have_content(plan.description)
      expect(page).to have_content('Credit or debit card')
      fill_stripe_elements(card: '4000000000000002')

      click_button('Enroll Membership for $10/mo')
      using_wait_time(10) do
        expect(page).to have_content('Your card was declined')
      end
    end
  end
end
