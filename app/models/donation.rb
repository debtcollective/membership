# frozen_string_literal: true

# == Schema Information
#
# Table name: donations
#
#  id                 :bigint           not null, primary key
#  amount             :money
#  charge_data        :jsonb            not null
#  charge_provider    :string           default("stripe")
#  customer_ip        :string
#  donation_type      :string
#  status             :integer          default("finished")
#  user_data          :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  card_id            :string
#  charge_id          :string
#  customer_stripe_id :string
#  user_id            :bigint
#
# Indexes
#
#  index_donations_on_charge_id  (charge_id) UNIQUE
#  index_donations_on_user_id    (user_id)
#
class Donation < ApplicationRecord
  DONATION_TYPES = {one_off: "ONE_OFF", subscription: "SUBSCRIPTION"}.freeze

  # These status are the same Stripe transactions return
  enum status: {succeeded: 0, pending: 1, failed: 2}

  belongs_to :user, optional: true

  validates :amount, :customer_stripe_id, :donation_type, presence: true
  validates :amount, numericality: {greater_than_or_equal_to: 5}, presence: true

  def date
    created_at.strftime("%m/%d/%Y")
  end

  def payment_type
    payment_method_details = charge_data.dig("payment_method_details", "card")
    return "" unless payment_method_details

    brand = payment_method_details.fetch("brand", "Credit Card")
    last4 = payment_method_details["last4"]

    "#{brand.capitalize} #{last4}"
  end

  def contributor_name
    name = user_data.dig("name")

    if name.blank? && user_id
      name = user.name
    end

    name
  end

  def contributor_email
    email = user_data.dig("email")

    if email.blank? && user_id
      email = user.email
    end

    email
  end

  def receipt_url
    # backwards compatibility
    if data = charge_data.dig("data")
      return data.dig("receipt_url")
    end

    charge_data.dig("receipt_url")
  end

  def receipt_number
    # backwards compatibility
    if data = charge_data.dig("data")
      return data.dig("receipt_number")
    end

    charge_data.dig("receipt_number")
  end
end
