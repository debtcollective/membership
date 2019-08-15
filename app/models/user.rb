# frozen_string_literal: true

class User < ApplicationRecord
  before_save { email.downcase! }

  USER_ROLES = { admin: 'admin', user: 'user' }.freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true

  has_one :subscription

  def full_name
    "#{first_name} #{last_name}"
  end
end
