# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserProfilesController, type: :controller do
  describe "PATCH #update" do
    it "with valid params it updates the profile" do
      user = FactoryBot.create(:user, email: "example@debtcollective.org")
      valid_attributes = FactoryBot.attributes_for(:user_profile)

      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      put :update, params: {id: 1, user_profile: valid_attributes}
      user_profile = user.user_profile

      expect(response.status).to eq(200)
      expect(user_profile.first_name).to eq(valid_attributes[:first_name])
    end
  end
end
