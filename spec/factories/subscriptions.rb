# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    user
    plan
    active { true }
  end
end
