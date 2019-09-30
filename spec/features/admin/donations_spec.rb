# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Manages donations', type: :feature do
  let!(:admin) { FactoryBot.create(:user, admin: true) }

  before(:each) do
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(admin)
  end

  describe 'home' do
    let!(:donation_1) { FactoryBot.create(:donation) }
    let!(:donation_2) { FactoryBot.create(:donation) }

    it 'presents a list of donations' do
      visit '/admin/donations'
      expect(page).to have_content('Donations')

      expect(page).to have_content(donation_1.amount)
      expect(page).to have_content(donation_2.amount)
    end
  end
end
