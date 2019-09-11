# frozen_string_literal: true

class Plan < ApplicationRecord
  validates :name, :headline, :amount, presence: true
  validates :amount, numericality: true
  has_rich_text :description

  has_many :subscriptions, through: :subscriptions
end
