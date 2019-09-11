# frozen_string_literal: true

require 'rails_helper'

describe 'User - manages their profile', type: :feature do
  describe 'home' do
    let(:user) { FactoryBot.create(:user) }

    it 'can edit their own data' do
      visit user_path(user)
      expect(page).to have_content('Saved Cardsg')

      cards.each do |card|
        within "#card-#{card.id}" do
          expect(page).to have_content(card.brand)
          expect(page).to have_content(card.exp_month)
          expect(page).to have_content(card.exp_year)
          expect(page).to have_content(card.last_digits)
        end
      end
    end
  end
end
