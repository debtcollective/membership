# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                      :bigint           not null, primary key
#  admin                   :boolean          default(FALSE)
#  avatar_url              :string
#  banned                  :boolean          default(FALSE)
#  confirmation_sent_at    :datetime
#  confirmed_at            :datetime
#  custom_fields           :jsonb
#  email                   :string
#  email_token             :string
#  name                    :string
#  registration_ip_address :inet
#  username                :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  external_id             :bigint
#  stripe_id               :string
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
        FactoryBot.create(:subscription_with_donation, user: user)
      end
    end

    factory :user_with_subscription_and_stripe do
      after(:create) do |user|
        FactoryBot.create(:subscription_with_donation, user: user)

        user.stripe_id = Stripe::Customer.create({email: user.email, description: "FactoryBot test user"}).id
        user.save
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
