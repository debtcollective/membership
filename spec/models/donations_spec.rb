# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Donation, type: :model do
  let(:donation) { FactoryBot.build_stubbed(:donation) }

  subject { donation }

  describe 'attributes' do
    it { is_expected.to respond_to(:amount) }
    it { is_expected.to respond_to(:card_id) }
    it { is_expected.to respond_to(:customer_stripe_id) }
    it { is_expected.to respond_to(:donation_type) }
    it { is_expected.to respond_to(:customer_ip) }
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:card_id) }
    it { is_expected.to validate_presence_of(:customer_stripe_id) }
    it { is_expected.to validate_presence_of(:donation_type) }
    it { is_expected.to allow_value(1235.123).for(:amount) }
  end
end
