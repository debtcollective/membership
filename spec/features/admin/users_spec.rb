# frozen_string_literal: true

require "rails_helper"

describe "Admin - Manages users", type: :feature, js: true do
  let!(:admin) { FactoryBot.create(:user, admin: true) }

  before(:each) do
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(admin)
  end

  describe "home" do
    let!(:user_1) { FactoryBot.create(:user) }
    let!(:user_2) { FactoryBot.create(:user) }

    it "presents a list of users" do
      visit "/admin/users"
      expect(page).to have_content("Users")

      expect(page).to have_content(user_1.name)
      expect(page).to have_content(user_1.email)

      expect(page).to have_content(user_2.name)
      expect(page).to have_content(user_2.email)
    end
  end

  describe "edit a user" do
    let!(:user) { FactoryBot.create(:user) }
    let(:user_modified_attributes) { FactoryBot.attributes_for(:user) }

    it "allows changing user information" do
      visit "/admin/users"
      expect(page).to have_content("Users")

      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)

      click_link("Edit", href: edit_admin_user_path(user))

      expect(page).to have_content("Editing User")

      fill_in "Name", with: user_modified_attributes[:name]
      fill_in "Email", with: user_modified_attributes[:email]
      click_button "Update User"

      expect(page).to have_content("User was successfully updated.")

      expect(page).to_not have_content(user.name)
      expect(page).to_not have_content(user.email)

      expect(page).to have_content(user_modified_attributes[:name])
      expect(page).to have_content(user_modified_attributes[:email])
    end
  end
end
