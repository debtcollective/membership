# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    user_role { User::USER_ROLES[:user] }
    email { Faker::Internet.email }
    discourse_id { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
