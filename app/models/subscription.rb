# frozen_string_literal: true

class Subscription < ApplicationRecord
  before_create :store_start_date

  belongs_to :user, optional: true
  belongs_to :plan

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :plan

  validates :plan_id, presence: true
  validates :user_id, uniqueness: { scope: %i[plan_id active] }, if: :user?

  scope :active, -> { where(active: true) }

  def user?
    !user_id.blank?
  end

  private

  def store_start_date
    self.start_date = DateTime.now if start_date.nil?
  end
end
