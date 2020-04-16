# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  admin         :boolean          default(FALSE)
#  avatar_url    :string
#  banned        :boolean          default(FALSE)
#  custom_fields :jsonb
#  email         :string
#  name          :string
#  username      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  external_id   :bigint
#  stripe_id     :string
#
FactoryBot.define do
  sequence :external_id do |n|
    n
  end

  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    external_id { generate(:external_id) }
    stripe_id { Faker::Internet.uuid }
  end
end
