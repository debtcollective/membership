# frozen_string_literal: true

require 'rails_helper'

describe 'User - manages their profile', type: :feature, js: true do
  describe 'home' do
    let(:user) { FactoryBot.create(:user) }
    let(:new_data) { FactoryBot.attributes_for(:user) }

    it 'can edit their own data' do
      visit user_path(user)

      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)
    end
  end
end
