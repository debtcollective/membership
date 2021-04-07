# == Schema Information
#
# Table name: user_profiles
#
#  id                       :bigint           not null, primary key
#  address_city             :string
#  address_country          :string
#  address_country_code     :string
#  address_county           :string
#  address_lat              :decimal(8, 6)
#  address_line1            :string
#  address_line2            :string
#  address_long             :decimal(9, 6)
#  address_state            :string
#  address_zip              :string
#  birthday                 :date
#  custom_fields            :jsonb
#  first_name               :string
#  last_name                :string
#  phone_number             :string
#  profile_completed        :boolean          default(FALSE)
#  subscribed_to_newsletter :boolean
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  user_id                  :bigint
#
# Indexes
#
#  index_user_profiles_on_profile_completed  (profile_completed)
#  index_user_profiles_on_user_id            (user_id)
#
class UserProfile < ApplicationRecord
  TITLES = ["Mr", "Mrs", "Ms", "Miss", "Dr", "Mx", "Profesor"]

  validation :title, inclusion: {in: TITLES}
end
