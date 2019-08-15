# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    name { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
