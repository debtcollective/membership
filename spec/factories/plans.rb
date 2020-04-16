# frozen_string_literal: true

# == Schema Information
#
# Table name: plans
#
#  id          :bigint           not null, primary key
#  amount      :money
#  description :text
#  headline    :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :plan do
    name { Faker::Lorem.sentence(word_count: 3) }
    headline { Faker::Lorem.sentence(word_count: 6) }
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
