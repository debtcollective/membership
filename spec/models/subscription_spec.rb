# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id             :bigint           not null, primary key
#  active         :boolean
#  last_charge_at :datetime
#  start_date     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  plan_id        :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_subscriptions_on_plan_id                         (plan_id)
#  index_subscriptions_on_user_id                         (user_id)
#  index_subscriptions_on_user_id_and_plan_id_and_active  (user_id,plan_id,active) UNIQUE
#
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
    it { is_expected.to validate_presence_of(:plan_id) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:plan_id, :active).ignoring_case_sensitivity }
  end
end
