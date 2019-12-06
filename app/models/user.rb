# frozen_string_literal: true

class User < ApplicationRecord
  include ActionView::Helpers::DateHelper

  SSO_ATTRIBUTES = %w[admin avatar_url banned custom_fields email name username].freeze

  has_many :subscriptions
  has_many :cards
  has_many :donations

  validates :external_id, presence: true

  def self.find_or_create_from_sso(payload)
    external_id = payload.fetch('external_id')

    user = User.find_or_initialize_by(external_id: external_id)
    new_record = user.new_record?

    # Update SSO fields
    SSO_ATTRIBUTES.each do |sso_attribute|
      user[sso_attribute] = payload[sso_attribute]
    end

    user.save

    [user, new_record]
  end

  def admin?
    !!admin
  end

  def current_streak
    return nil unless active_subscription

    start_date ||= active_subscription.start_date

    return 1 if (Date.today - start_date.to_date).zero? # first month of subscription

    ((Date.today - start_date.to_date).to_f / 365 * 12).round
  end

  def active_subscription
    subscriptions.active unless subscriptions.active.blank?
  end
end
