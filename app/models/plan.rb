# frozen_string_literal: true

class Plan < ApplicationRecord
  validates :name, :description, :amount, presence: true
  validates :amount, numericality: true

  has_many :subscriptions, through: :subscriptions
end
