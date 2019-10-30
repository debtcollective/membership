# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPlanChange, type: :model do
  let!(:user_plan_change) { FactoryBot.create(:user_plan_change) }

  subject { user_plan_change }

  describe 'attributes' do
    it { is_expected.to respond_to(:user) }
    it { is_expected.to respond_to(:old_plan_id) }
    it { is_expected.to respond_to(:new_plan_id) }
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:old_plan_id) }
    it { is_expected.to validate_presence_of(:new_plan_id) }

    it { is_expected.to validate_uniqueness_of(:user_id) }
  end
end
