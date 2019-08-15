# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name  { 'Doe' }
    user_role { 'User' }
    email { 'foo@bar.com' }
    discourse_id { '12sajdh1981983jndan' }
  end
end
