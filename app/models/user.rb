# frozen_string_literal: true

class User < ApplicationRecord
  include ActionView::Helpers::DateHelper

  SSO_ATTRIBUTES = %w[admin banned username email avatar_url custom_fields].freeze

  has_one :subscription
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
    return 'Currently, you don\'t own an active subscribption' unless subscription

    start_date ||= subscription.start_date

    time_ago_in_words(start_date)
  end
end
