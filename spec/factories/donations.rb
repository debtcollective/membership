# frozen_string_literal: true

# == Schema Information
#
# Table name: donations
#
#  id                 :bigint           not null, primary key
#  amount             :money
#  charge_data        :jsonb            not null
#  charge_provider    :string           default("stripe")
#  customer_ip        :string
#  donation_type      :string
#  status             :integer
#  user_data          :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  card_id            :string
#  charge_id          :string
#  customer_stripe_id :string
#  fund_id            :bigint
#  user_id            :bigint
#
# Indexes
#
#  index_donations_on_charge_id  (charge_id) UNIQUE
#  index_donations_on_fund_id    (fund_id)
#  index_donations_on_user_id    (user_id)
#
FactoryBot.define do
  factory :donation do
    amount { Faker::Number.within(range: 5..500) }
    customer_stripe_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    card_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    donation_type { [Donation::DONATION_TYPES[:one_off], Donation::DONATION_TYPES[:subscription]].sample }
    customer_ip { Faker::Internet.ip_v4_address }
  end
end
