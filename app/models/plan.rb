# frozen_string_literal: true

# == Schema Information
#
# Table name: plans
#
#  id          :bigint           not null, primary key
#  amount      :money
#  description :text
#  headline    :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Plan < ApplicationRecord
  validates :name, :headline, :amount, presence: true
  validates :amount, numericality: true
  has_rich_text :description

  has_many :subscriptions, dependent: :restrict_with_error
end
