# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Card, type: :model do
  let!(:card) { FactoryBot.create(:card) }

  subject { card }

  describe 'attributes' do
    it { is_expected.to respond_to(:brand) }
    it { is_expected.to respond_to(:user_id) }
    it { is_expected.to respond_to(:exp_month) }
    it { is_expected.to respond_to(:exp_year) }
    it { is_expected.to respond_to(:last_digits) }
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
  end
end
