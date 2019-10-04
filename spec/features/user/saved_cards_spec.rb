# frozen_string_literal: true

require 'rails_helper'

describe 'User - Manages saved cards', type: :feature do
  describe 'home' do
    let(:user) { FactoryBot.create(:user) }
    let!(:cards) { FactoryBot.create_list(:card, 5, user_id: user.id) }

    before(:each) do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
    end

    it 'presents a list of subscriptions' do
      visit user_cards_path(user)
      expect(page).to have_content('Saved Cards')

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
