# frozen_string_literal: true

require "rails_helper"

RSpec.describe DonationService, type: :service do
  describe ".invite_user" do
    let(:user) { FactoryBot.create(:user) }

    it "creates a discourse invite" do
      discourse = DiscourseService.new(user)

      invite = discourse.invite_user

      expect(invite).to eq(true)
    end
  end
end
