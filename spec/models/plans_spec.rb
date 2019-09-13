# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plan, type: :model do
  let(:plan) { FactoryBot.build_stubbed(:plan) }

  subject { plan }

  describe 'attributes' do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:headline) }
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:amount) }
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:headline) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to allow_value(1235.123).for(:amount) }
  end
end
