# frozen_string_literal: true

require 'rails_helper'

describe 'User - manages their profile', type: :feature, js: true do
  describe 'home' do
    let(:user) { FactoryBot.create(:user) }
    let(:new_data) { FactoryBot.attributes_for(:user) }

    it 'can edit their own data' do
      visit user_path(user)

      expect(page).to have_content(user.first_name)
      expect(page).to have_content(user.last_name)
      expect(page).to have_content(user.email)

      click_on 'Edit'

      expect(page).to have_content('Editing User')

      fill_in 'First name', with: new_data[:first_name]
      fill_in 'Email', with: new_data[:email]

      click_button 'Update User'

      user.reload
      expect(user.first_name).to eq(new_data[:first_name])

      expect(page).to have_content(user.first_name)
      expect(page).to have_content(user.last_name)
    end
  end
end
