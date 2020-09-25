# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                         :bigint           not null, primary key
#  admin                      :boolean          default(FALSE)
#  avatar_url                 :string
#  banned                     :boolean          default(FALSE)
#  custom_fields              :jsonb
#  email                      :string
#  email_confirmation_sent_at :datetime
#  email_confirmation_token   :string
#  email_confirmed_at         :datetime
#  name                       :string
#  username                   :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  external_id                :bigint
#  stripe_id                  :string
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
  end
end
