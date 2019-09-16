# frozen_string_literal: true

require 'rails_helper'

describe 'User - manages their profile', type: :feature, js: true do
  describe 'home' do
    let(:user) { FactoryBot.create(:user) }

    it 'can edit their own data' do
      visit user_path(user)

      expect(page).to have_content(user.first_name)
      expect(page).to have_content(user.last_name)
      expect(page).to have_content(user.email)

      click_on 'Edit'
    end
  end
end
