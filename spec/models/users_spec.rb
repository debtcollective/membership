# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build_stubbed(:user) }

  subject { user }

  describe 'attributes' do
    it { is_expected.to respond_to(:first_name) }
    it { is_expected.to respond_to(:last_name) }
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:user_role) }
    it { is_expected.to respond_to(:discourse_id) }
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('example@domain.com').for(:email) }
  end

  describe '.email' do
    context 'when email is not present' do
      before { user.email = ' ' }
      it { is_expected.to_not be_valid }
    end

    context 'when email address is already taken' do
      before do
        user_with_same_email = user.dup
        user_with_same_email.save
      end

      it { is_expected.to_not be_valid }
    end

    context 'email address with mixed case' do
      let(:user) { FactoryBot.build(:user) }
      let(:mixed_case_email) { 'Foo@ExAMPle.CoM' }

      it 'should be saved as all lower-case' do
        user.email = mixed_case_email
        user.save
        expect(user.reload.email).to eq(mixed_case_email.downcase)
      end
    end
  end

  describe '.full_name' do
    context 'when both first and last name were filled' do
      let(:user) { FactoryBot.build_stubbed(:user) }

      it 'returns the full_name' do
        expect(user.full_name).to eql("#{user.first_name} #{user.last_name}")
      end
    end
  end
end
