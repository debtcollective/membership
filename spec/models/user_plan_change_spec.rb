# frozen_string_literal: true

# == Schema Information
#
# Table name: user_plan_changes
#
#  id          :bigint           not null, primary key
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  new_plan_id :string
#  old_plan_id :string
#  user_id     :string
#
require 'rails_helper'

RSpec.describe UserPlanChange, type: :model do
  let!(:user) { FactoryBot.create(:user) }
  let!(:plan1) { FactoryBot.create(:plan) }
  let!(:plan2) { FactoryBot.create(:plan) }
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

    it 'can have multiple plan changes' do
      plan_change = FactoryBot.create(:user_plan_change, user: user, status: 'succeeded', new_plan_id: plan1.id, old_plan_id: plan2.id)
      second_plan_change = user.user_plan_changes.new(new_plan_id: plan2, old_plan_id: plan1)
      second_plan_change.save

      expect(second_plan_change.errors).to be_empty
    end

    it 'allows only one pending plan change' do
      pending_plan_change = FactoryBot.create(:user_plan_change, user: user, status: 'pending', new_plan_id: plan1.id, old_plan_id: plan2.id)

      second_pending_plan_change = user.user_plan_changes.new(new_plan_id: plan2, old_plan_id: plan1)
      second_pending_plan_change.save

      expect(second_pending_plan_change.errors.full_messages).to eq(['already has a pending plan change'])
    end
  end
end
