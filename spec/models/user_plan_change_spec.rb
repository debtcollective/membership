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
  end
end
