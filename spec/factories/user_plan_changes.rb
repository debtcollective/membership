# frozen_string_literal: true

FactoryBot.define do
  factory :user_plan_change do
    old_plan_id { Faker::Internet.uuid }
    new_plan_id { Faker::Internet.uuid }
    user
  end
end
