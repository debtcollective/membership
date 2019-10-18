# frozen_string_literal: true

require 'rails_helper'

describe 'As a logged user that wants to change plans', type: :feature do
  let!(:active_plan) { FactoryBot.create(:plan) }
  let!(:new_plan) { FactoryBot.create(:plan) }
  let!(:user) { FactoryBot.create(:user, stripe_id: nil) }
  let!(:subscription) { FactoryBot.create(:subscription, plan: active_plan, user: user) }

  it 'I am able to downgrade/upgrade my plan', js: true do
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
    expect(UserPlanChange.where(user_id: user.id).length).to be(0)
    visit "/users/#{user.id}"

    within '#contact-data' do
      expect(page).to have_content(user.name)
    end
    expect(page).to have_content("You're subscribed")

    click_link 'Change Subscription'

    expect(page).to have_content('Available plans')

    within "#plan-#{active_plan.id}" do
      expect(page).to have_content(active_plan.name)
    end

    within "#plan-#{new_plan.id}" do
      expect(page).to have_content(new_plan.name)
      click_button 'Pick plan'
    end

    expect(page).to have_content('We have changed your subscription successfully.')
    expect(UserPlanChange.where(user_id: user.id).length).to be(1)
  end
end
