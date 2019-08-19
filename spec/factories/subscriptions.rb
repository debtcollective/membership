# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    active { true }
    user
    plan
  end
end
