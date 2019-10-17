# frozen_string_literal: true

class UserPlanChange < ApplicationRecord
  belongs_to :user

  validates :old_plan_id, :new_plan_id, :user_id, presence: true
  validates :user_id, uniqueness: true
end
