# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Manages user subscriptions', type: :feature, js: true do
  describe 'home' do
    let!(:subscription_1) { FactoryBot.create(:subscription) }
    let!(:subscription_2) { FactoryBot.create(:subscription) }

    it 'presents a list of subscriptions' do
      visit '/admin/subscriptions'
      expect(page).to have_content('Subscriptions')

      expect(page).to have_content(subscription_1.user.full_name)
      expect(page).to have_content(subscription_1.plan.name)
      expect(page).to have_content(subscription_1.plan.amount)

      expect(page).to have_content(subscription_2.user.full_name)
      expect(page).to have_content(subscription_2.plan.name)
      expect(page).to have_content(subscription_2.plan.amount)
    end
  end

  describe 'edit a subscription' do
    let!(:subscription) { FactoryBot.create(:subscription) }
    let!(:new_plan) { FactoryBot.create(:plan) }

    it 'allows changing the plan and status of a user subscription' do
      expect(subscription.active).to eq(true)

      visit '/admin/subscriptions'
      expect(page).to have_content('Subscriptions')

      expect(page).to have_content(subscription.user.full_name)
      click_link('Edit', href: edit_admin_subscription_path(subscription))

      expect(page).to have_content('Editing Subscription')
      select new_plan.name, from: 'subscription[plan_id]'

      uncheck 'subscription[active]'

      click_button 'Update Subscription'

      expect(page).to have_content('Subscription was successfully updated.')

      subscription.reload

      expect(subscription.active).to eq(false)
      expect(subscription.plan_id).to eq(new_plan.id)
    end
  end

  describe 'subscriptions details' do
    let!(:subscription) { FactoryBot.create(:subscription) }

    it 'contains related donations' do
      subscription_donations = FactoryBot.create_list(:subscription_donation, 5, subscription_id: subscription.id)

      visit '/admin/subscriptions'
      expect(page).to have_content('Subscriptions')

      expect(page).to have_content(subscription.user.full_name)
      click_link('Show', href: admin_subscription_path(subscription))

      expect(page).to have_content(subscription.plan.name)

      subscription_donations.each do |subscription_donation|
        donation = subscription_donation.donation
        within "#donation-#{donation.id}" do
          expect(page).to have_content(donation.amount)
          expect(page).to have_content(donation.created_at)
        end
      end
    end
  end
end
