# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :bigint           not null, primary key
#  activated_at         :datetime
#  active               :boolean          default(FALSE)
#  admin                :boolean          default(FALSE)
#  avatar_url           :string
#  banned               :boolean          default(FALSE)
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  custom_fields        :jsonb
#  email                :string
#  email_token          :string
#  name                 :string
#  username             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_id          :bigint
#  stripe_id            :string
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  subject { user }

  describe "attributes" do
    it { is_expected.to respond_to(:admin) }
    it { is_expected.to respond_to(:avatar_url) }
    it { is_expected.to respond_to(:banned) }
    it { is_expected.to respond_to(:custom_fields) }
    it { is_expected.to respond_to(:external_id) }
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:stripe_id) }
    it { is_expected.to respond_to(:username) }
    it { is_expected.to be_valid }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end

  describe "associations" do
    it { is_expected.to have_many(:subscriptions) }
    it { is_expected.to have_many(:donations) }
  end

  describe ".find_or_create_from_sso" do
    it "creates and returns a new user" do
      payload = JSON.parse(file_fixture("jwt_sso_payload.json").read)

      user, new_record = User.find_or_create_from_sso(payload)

      expect(new_record).to eq(true)
      expect(user.persisted?).to eq(true)
      expect(user.external_id).to eq(payload["external_id"])
    end

    it "returns existing user by external_id" do
      payload = JSON.parse(file_fixture("jwt_sso_payload.json").read)
      external_id = payload["external_id"]
      FactoryBot.create(:user, external_id: external_id)

      user, new_record = User.find_or_create_from_sso(payload)

      expect(new_record).to eq(false)
      expect(user.persisted?).to eq(true)
      expect(user.external_id).to eq(external_id)
    end

    it "returns existing user by email when external_id is nil" do
      payload = JSON.parse(file_fixture("jwt_sso_payload.json").read)
      external_id = payload["external_id"]
      email = payload["email"]
      FactoryBot.create(:user, email: email, external_id: nil)

      user, new_record = User.find_or_create_from_sso(payload)

      expect(new_record).to eq(false)
      expect(user.persisted?).to eq(true)
      expect(user.email).to eq(email)
      expect(user.external_id).to eq(external_id)
    end
  end
end
