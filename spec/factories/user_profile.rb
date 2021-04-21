FactoryBot.define do
  factory :user_profile do
    title { UserProfile::TITLES.sample }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birthday { 2.years.ago }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    address_line1 { Faker::Address.street_address }
    address_line2 { Faker::Address.secondary_address }
    address_city { Faker::Address.city }
    address_state { Faker::Address.state }
    address_zip { Faker::Address.zip_code }
    address_country { Faker::Address.country }
    address_country_code { Faker::Address.country_code }
    address_lat { Faker::Address.latitude }
    address_long { Faker::Address.longitude }
    facebook { Faker::Internet.username }
    twitter { Faker::Internet.username }
    instagram { Faker::Internet.username }
    website { Faker::Internet.url }
    user
  end
end
