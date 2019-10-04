# frozen_string_literal: true

FactoryBot.define do
  sequence :external_id do |n|
    n
  end

  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    external_id { generate(:external_id) }
    stripe_id { Faker::Internet.uuid }
  end
end
