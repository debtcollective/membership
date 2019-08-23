class SubscriptionDonation < ApplicationRecord
  belongs_to :donation
  belongs_to :subscription

  validates :donation_id, :subscription_id, presence: true
end
