# frozen_string_literal: true

class User < ApplicationRecord
  SSO_ATTRIBUTES = %i[admin banned username email avatar_url custom_fields].freeze

  has_one :subscription
  has_many :cards

  validates :external_id, presence: true

  def self.find_or_create_from_sso(payload)
    external_id = payload.fetch(:external_id)

    user = User.find_or_initialize_by(external_id: external_id)
    new_record = user.new_record?

    # Update SSO fields
    SSO_ATTRIBUTES.each { |sso_attribute| user[sso_attribute] = payload[sso_attribute] }

    user.save

    user, new_record
  end
end
