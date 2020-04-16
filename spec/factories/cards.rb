# frozen_string_literal: true

# == Schema Information
#
# Table name: cards
#
#  id             :bigint           not null, primary key
#  brand          :string
#  exp_month      :integer
#  exp_year       :integer
#  last_digits    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  stripe_card_id :string
#  user_id        :bigint
#
# Indexes
#
#  index_cards_on_user_id  (user_id)
#
FactoryBot.define do
  factory :card do
    user
    brand { %w[visa master amex].sample }
    exp_month { Faker::Stripe.month }
    exp_year { Faker::Stripe.year }
    last_digits { Faker::Number.number(digits: 4) }
  end
end
