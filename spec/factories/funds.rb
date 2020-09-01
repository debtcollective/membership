# == Schema Information
#
# Table name: funds
#
#  id         :bigint           not null, primary key
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_funds_on_slug  (slug) UNIQUE
#
FactoryBot.define do
  factory :fund do
    name { Faker::Lorem.sentence(word_count: 2) }
    slug { Faker::Internet.slug }
  end
end
