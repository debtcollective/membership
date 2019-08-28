# frozen_string_literal: true

class Donation < ApplicationRecord
  DONATION_TYPES = { one_off: 'ONE_OFF', subscription: 'SUBSCRIPTION' }.freeze
  enum status: %i[finished pending archived failed]

  validates :amount, :customer_stripe_id, :donation_type, presence: true
  validates :amount, numericality: true
end
