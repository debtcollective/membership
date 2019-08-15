# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    name { Faker::Lorem.words(number: 4) }
    description { Faker::Lorem.paragraph }
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
