# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :plan

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :plan

  validates :plan_id, presence: true
  validates :user_id, uniqueness: { scope: %i[plan_id active] }, if: :user?

  def user?
    !user_id.blank?
  end
end
