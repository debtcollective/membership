# frozen_string_literal: true

class User < ApplicationRecord
  before_save { email.downcase! }

  USER_ROLES = { admin: 'admin', user: 'user' }.freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze

  has_one :subscription
  has_many :cards

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.find_or_create_from_sso(payload)
    # create user from SSO
  end
end
