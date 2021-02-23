# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :bigint           not null, primary key
#  activated_at         :datetime
#  active               :boolean          default(FALSE)
#  admin                :boolean          default(FALSE)
#  avatar_url           :string
#  banned               :boolean          default(FALSE)
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  custom_fields        :jsonb
#  email                :string
#  email_token          :string
#  name                 :string
#  username             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_id          :bigint
#  stripe_id            :string
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
FactoryBot.define do
  sequence :external_id do |n|
    n
  end

  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }

    factory :user_with_subscription do
      after(:create) do |user|
        FactoryBot.create(:subscription, user: user)
      end
    end

    factory :user_with_confirmation_token do
      confirmation_token { SecureRandom.hex(20) }
    end

    factory :user_with_email_token do
      email_token { SecureRandom.hex(20) }
    end
  end
end
