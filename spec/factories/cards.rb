# frozen_string_literal: true

FactoryBot.define do
  factory :card do
    user
    brand { %w[visa master amex].sample }
    exp_month { Faker::Stripe.month }
    exp_year { Faker::Stripe.year }
    last_digits { Faker::Number.number(digits: 4) }
  end
end
