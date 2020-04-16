# frozen_string_literal: true

# == Schema Information
#
# Table name: donations
#
#  id                 :bigint           not null, primary key
#  amount             :money
#  customer_ip        :string
#  donation_type      :string
#  status             :integer          default("finished")
#  user_data          :json             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  card_id            :string
#  customer_stripe_id :string
#  user_id            :bigint
#
# Indexes
#
#  index_donations_on_user_id  (user_id)
#
class Donation < ApplicationRecord
  DONATION_TYPES = { one_off: 'ONE_OFF', subscription: 'SUBSCRIPTION' }.freeze
  enum status: %i[finished pending archived failed]

  validates :amount, :customer_stripe_id, :donation_type, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 5 }, presence: true
end
