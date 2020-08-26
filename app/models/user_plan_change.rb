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
class UserPlanChange < ApplicationRecord
  belongs_to :user

  enum status: {succeeded: 0, pending: 1, failed: 2}

  validates :old_plan_id, :new_plan_id, :user_id, presence: true
  validates :user_id, uniqueness: true
end
