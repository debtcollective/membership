# == Schema Information
#
# Table name: subscription_donations
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  donation_id     :bigint
#  subscription_id :bigint
#
# Indexes
#
#  index_subscription_donations_on_donation_id                      (donation_id)
#  index_subscription_donations_on_subscription_id                  (subscription_id)
#  index_subscription_donations_on_subscription_id_and_donation_id  (subscription_id,donation_id) UNIQUE
#
class SubscriptionDonation < ApplicationRecord
  belongs_to :donation
  belongs_to :subscription

  validates :donation_id, :subscription_id, presence: true
end
