# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan

  validates :user_id, :plan_id, presence: true
  validates :user_id, uniqueness: { scope: %i[plan_id active] }
end
