# frozen_string_literal: true

FactoryBot.define do
  factory :subscription_donation do
    subscription
    donation
  end
end
