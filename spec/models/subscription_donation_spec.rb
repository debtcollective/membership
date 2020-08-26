# frozen_string_literal: true

# == Schema Information
#
# Table name: subscription_donations
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  donation_id     :bigint
#  subscription_id :bigint
#
# Indexes
#
#  index_subscription_donations_on_donation_id                      (donation_id)
#  index_subscription_donations_on_subscription_id                  (subscription_id)
#  index_subscription_donations_on_subscription_id_and_donation_id  (subscription_id,donation_id) UNIQUE
#
require 'rails_helper'

RSpec.describe SubscriptionDonation, type: :model do
  let!(:subscription_donation) { FactoryBot.create(:subscription_donation) }

  subject { subscription_donation }

  describe 'attributes' do
    it { is_expected.to respond_to(:donation_id) }
    it { is_expected.to respond_to(:subscription_id) }
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:donation_id) }
    it { is_expected.to validate_presence_of(:subscription_id) }
  end
end
