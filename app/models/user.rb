# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  admin         :boolean          default(FALSE)
#  avatar_url    :string
#  banned        :boolean          default(FALSE)
#  custom_fields :jsonb
#  email         :string
#  name          :string
#  username      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  external_id   :bigint
#  stripe_id     :string
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

  def admin?
    !!admin
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
