# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build_stubbed(:user) }

  subject { user }

  describe 'attributes' do
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

  describe 'validations' do
    it { is_expected.to validate_presence_of(:external_id) }
  end

  describe '.find_or_create_from_sso' do
    it 'creates and returns a new user' do
      payload = JSON.parse(file_fixture('jwt_sso_payload.json').read)

      user, new_record = User.find_or_create_from_sso(payload)

      expect(new_record).to eql(true)
      expect(user.persisted?).to eql(true)
      expect(user.external_id).to eql(payload['external_id'])
      expect(user.custom_fields).to eql(payload['custom_fields'])
    end

    it 'returns existing user if exists' do
      payload = JSON.parse(file_fixture('jwt_sso_payload.json').read)

      user, new_record = User.find_or_create_from_sso(payload)

      expect(new_record).to eql(true)
      expect(user.persisted?).to eql(true)
      expect(user.external_id).to eql(payload['external_id'])
      expect(user.custom_fields).to eql(payload['custom_fields'])
    end
  end
end
