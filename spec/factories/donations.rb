# frozen_string_literal: true

# == Schema Information
#
# Table name: donations
#
#  id                 :bigint           not null, primary key
#  amount             :money
#  customer_ip        :string
#  donation_type      :string
#  status             :integer          default("finished")
#  user_data          :json             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  card_id            :string
#  customer_stripe_id :string
#  user_id            :bigint
#
# Indexes
#
#  index_donations_on_user_id  (user_id)
#
FactoryBot.define do
  factory :donation do
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    customer_stripe_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    card_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    donation_type { [Donation::DONATION_TYPES[:one_off], Donation::DONATION_TYPES[:subscription]].sample }
    customer_ip { Faker::Internet.ip_v4_address }
  end
end
