FactoryBot.define do
  factory :fund do
    name { Faker::Lorem.sentence(word_count: 2) }
    slug { Faker::Internet.slug }
  end
end
