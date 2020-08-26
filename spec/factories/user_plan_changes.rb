# frozen_string_literal: true

# == Schema Information
#
# Table name: user_plan_changes
#
#  id          :bigint           not null, primary key
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  new_plan_id :string
#  old_plan_id :string
#  user_id     :string
#
FactoryBot.define do
  factory :user_plan_change do
    old_plan_id { Faker::Internet.uuid }
    new_plan_id { Faker::Internet.uuid }
    user
  end
end
