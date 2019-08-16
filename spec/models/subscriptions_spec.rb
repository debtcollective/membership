# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:subscription) { FactoryBot.create(:subscription) }

  subject { subscription }

  describe 'attributes' do
    it { is_expected.to respond_to(:user_id) }
    it { is_expected.to respond_to(:plan_id) }
    it { is_expected.to respond_to(:active) }
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:plan_id) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:plan_id, :active).ignoring_case_sensitivity }
  end
end
