# frozen_string_literal: true

FactoryBot.define do
  factory :donation do
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    customer_stripe_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    card_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    donation_type { [Donation::DONATION_TYPES[:one_off], Donation::DONATION_TYPES[:subscription]].sample }
    customer_ip { Faker::Internet.ip_v4_address }
  end
end
