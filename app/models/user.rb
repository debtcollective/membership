# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :bigint           not null, primary key
#  admin                :boolean          default(FALSE)
#  avatar_url           :string
#  banned               :boolean          default(FALSE)
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  custom_fields        :jsonb
#  email                :string
#  name                 :string
#  username             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_id          :bigint
#  stripe_id            :string
#
class User < ApplicationRecord
  include ActionView::Helpers::DateHelper

  SSO_ATTRIBUTES = %w[
    admin
    avatar_url
    banned
    custom_fields
    email
    name
    username
  ].freeze

  has_many :subscriptions
  has_many :donations
  has_many :user_plan_changes

  def self.find_or_create_from_sso(payload)
    external_id = payload.fetch("external_id")

    user = User.find_or_initialize_by(external_id: external_id)
    new_record = user.new_record?

    # Update SSO fields
    SSO_ATTRIBUTES.each do |sso_attribute|
      user[sso_attribute] = payload[sso_attribute]
    end

    user.save

    [user, new_record]
  end

  def self.send_confirmation_instructions(attributes = {})
    user = User.find_by_email(attributes[:email])

    if user
      confirmation_token = user.confirmation_token || SecureRandom.hex(20)
      user.update_attributes(confirmation_token: confirmation_token, confirmation_sent_at: DateTime.now)
      UserMailer.confirmation_email(user: user).deliver_later
    else
      user = User.new
      user.errors.add(:base, "User not found")
    end

    user
  end

  def self.confirm_by_token(confirmation_token)
    user = User.find_by_confirmation_token(confirmation_token)

    if user
      user.update_attributes(confirmation_token: nil, confirmed_at: DateTime.now)
    else
      user = User.new
      user.errors.add(:base, "Invalid confirmation token")
    end

    user
  end

  def admin?
    !!admin
  end

  def confirmed?
    confirmed_at.present?
  end

  def current_streak
    subscription = active_subscription

    return nil unless subscription

    start_date = subscription.start_date
    today = Date.today

    months =
      (today.year * 12 + today.month) -
      (start_date.year * 12 + start_date.month)
    months += 1 if months == 0

    months
  end

  def pending_plan_change
    @pending_plan_change ||= user_plan_changes.where(status: :pending).first
  end

  def active_subscription
    @active_subscription ||= subscriptions.includes(:plan).where(active: true).last
  end
end
