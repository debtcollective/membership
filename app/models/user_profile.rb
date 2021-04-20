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
#  facebook                 :string
#  first_name               :string
#  instagram                :string
#  last_name                :string
#  metadata                 :jsonb
#  phone_number             :string
#  profile_completed        :boolean          default(FALSE)
#  registration_email       :string
#  subscribed_to_newsletter :boolean
#  title                    :string
#  twitter                  :string
#  website                  :string
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
  PHONE_NUMBER_REGEX = /\A\+[1-9]\d{1,14}\z/

  belongs_to :user

  validates :address_city, presence: true
  validates :address_country_code, presence: true, inclusion: {in: ISO3166::Country.all.map(&:alpha2)}
  validates :address_line1, presence: true
  validates :address_zip, presence: true
  validates :birthday, inclusion: {in: ->(date) { 15.years.ago..Date.today }}, allow_nil: true
  validates :facebook, format: {with: /[a-zA-Z0-9]+/}, allow_blank: true
  validates :first_name, presence: true
  validates :instagram, format: {with: /[a-zA-Z0-9]+/}, allow_blank: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, format: {with: PHONE_NUMBER_REGEX}
  validates :registration_email, presence: true, 'valid_email_2/email': true, uniqueness: {case_sensitive: false}
  validates :title, inclusion: {in: TITLES}, allow_nil: true
  validates :twitter, format: {with: /[a-zA-Z0-9]+/}, allow_blank: true
  validates :website, url: {allow_nil: true, no_local: true}
end
