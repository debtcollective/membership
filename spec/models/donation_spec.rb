# frozen_string_literal: true

# == Schema Information
#
# Table name: donations
#
#  id                 :bigint           not null, primary key
#  amount             :money
#  charge_data        :jsonb            not null
#  charge_provider    :string           default("stripe")
#  customer_ip        :string
#  donation_type      :string
#  status             :integer          default("finished")
#  user_data          :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  card_id            :string
#  charge_id          :string
#  customer_stripe_id :string
#  user_id            :bigint
#
# Indexes
#
#  index_donations_on_charge_id  (charge_id) UNIQUE
#  index_donations_on_user_id    (user_id)
#
require "rails_helper"

RSpec.describe Donation, type: :model do
  let(:donation) { FactoryBot.build_stubbed(:donation) }

  subject { donation }

  describe "attributes" do
    it { is_expected.to respond_to(:amount) }
    it { is_expected.to respond_to(:card_id) }
    it { is_expected.to respond_to(:customer_stripe_id) }
    it { is_expected.to respond_to(:donation_type) }
    it { is_expected.to respond_to(:customer_ip) }
    it { is_expected.to respond_to(:charge_data) }
    it { is_expected.to respond_to(:user_data) }
    it { is_expected.to be_valid }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:customer_stripe_id) }
    it { is_expected.to validate_presence_of(:donation_type) }
    it { is_expected.to allow_value(10).for(:amount) }
    it { is_expected.to_not allow_value(4).for(:amount) }
  end

  describe "#contributor_name" do
    it "returns name from user_data or user if available" do
      user_donation = FactoryBot.create(:donation, user: FactoryBot.create(:user, name: "DonatorSubject"))
      donation = FactoryBot.create(:donation, user_data: {name: "Anonymous"})
      donation_without_data = FactoryBot.create(:donation)

      expect(user_donation.contributor_name).to eq("DonatorSubject")
      expect(donation.contributor_name).to eq("Anonymous")
      expect(donation_without_data.contributor_name).to be_nil
    end
  end

  describe "#contributor_email" do
    it "returns email from user_data or user if available" do
      user_donation = FactoryBot.create(:donation, user: FactoryBot.create(:user, name: "DonatorSubject"))
      donation = FactoryBot.create(:donation, user_data: {email: "test@example.com"})
      donation_without_data = FactoryBot.create(:donation)

      expect(user_donation.contributor_email).to eq(user_donation.user.email)
      expect(donation.contributor_email).to eq("test@example.com")
      expect(donation_without_data.contributor_email).to be_nil
    end
  end

  describe "#receipt_url" do
    it "returns receipt_url from charge_data" do
      donation = FactoryBot.create(:donation, charge_data: {"data": {"receipt_url": "https://receipt.com", "receipt_number": "123"}})

      expect(donation.receipt_url).to eq("https://receipt.com")
      expect(donation.receipt_number).to eq("123")
    end

    it "returns receipt_url from charge_data without data key" do
      donation = FactoryBot.create(:donation, charge_data: {"receipt_url": "https://receipt.com", "receipt_number": "123"})

      expect(donation.receipt_url).to eq("https://receipt.com")
      expect(donation.receipt_number).to eq("123")
    end
  end
end
