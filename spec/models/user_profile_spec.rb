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
#  facebook                 :string
#  first_name               :string
#  instagram                :string
#  last_name                :string
#  phone_number             :string
#  profile_completed        :boolean          default(FALSE)
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
require "rails_helper"

RSpec.describe UserProfile, type: :model do
  let(:user_profile) { FactoryBot.create(:user_profile) }

  subject { user_profile }

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
