# frozen_string_literal: true

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
