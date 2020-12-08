# frozen_string_literal: true

require "rails_helper"

RSpec.describe DonationService, type: :service do
  let(:valid_params) do
    {
      address_city: Faker::Address.city,
      address_country_code: Faker::Address.country_code,
      address_line1: Faker::Address.street_address,
      address_zip: Faker::Address.zip_code,
      amount: 10,
      customer_ip: "127.0.0.1",
      email: Faker::Internet.email,
      fund_id: 1,
      name: Faker::Name.name,
      phone_number: Faker::PhoneNumber.phone_number,
      stripe_token: StripeMock.create_test_helper.generate_card_token
    }
  end

  before { StripeMock.start }
  after { StripeMock.stop }

  describe "validations" do
    subject { DonationService.new(valid_params) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).only_integer.is_greater_than_or_equal_to(5) }
    it { should validate_presence_of(:customer_ip) }
    it { should validate_presence_of(:fund_id) }
    it { should validate_presence_of(:phone_number) }
    it { should validate_presence_of(:stripe_token) }
    it { should validate_presence_of(:address_line1) }
    it { should validate_presence_of(:address_city) }
    it { should validate_presence_of(:address_zip) }
    it { should validate_presence_of(:address_country_code) }
    it { should validate_presence_of(:stripe_token) }
  end

  describe ".save_donation_with_user" do
    let(:user) { FactoryBot.create(:user) }
    let(:fund) { FactoryBot.create(:default_fund) }
    let!(:stripe_helper) { StripeMock.create_test_helper }

    it "creates a donation record" do
      params = valid_params.merge({
        fund_id: fund.id,
        name: user.name,
        email: user.email,
        stripe_token: stripe_helper.generate_card_token
      })
      donation_service = DonationService.new(params, user)

      donation, errors = donation_service.execute

      expect(errors.empty?).to eq(true)
      expect(donation).to be_persisted
      expect(donation.user_data["email"]).to eq(user.email)
      expect(donation.user_data["phone_number"]).to eq(
        params[:phone_number]
      )
      expect(donation.user_data["address_country"]).to eq(
        ISO3166::Country[params[:address_country_code]].name
      )
      expect(donation.user_data["address_country_code"]).to eq(
        params[:address_country_code]
      )
      expect(donation.amount.to_i).to eq(10)
      # Stripe stores the amount in cents
      expect(donation.charge_data["amount"]).to eq(donation.amount * 100)
      expect(donation.charge_data).to have_key("id")
      expect(donation.status).to eq("succeeded")
      expect(donation.fund).to eq(fund)
      expect(donation.customer_ip).to eq(params[:customer_ip])
    end

    it "returns error if charge is declined" do
      params = valid_params.merge({
        stripe_token: stripe_helper.generate_card_token
      })

      StripeMock.prepare_card_error(:card_declined)

      donation, errors = DonationService.new(params).execute

      expect(errors.empty?).to eq(false)
      expect(errors["base"]).to eq(["The card was declined"])
    end
  end

  describe ".save_donation_without_user" do
    let!(:stripe_helper) { StripeMock.create_test_helper }

    it "creates a donation record" do
      params = valid_params.merge({
        stripe_token: stripe_helper.generate_card_token
      })

      donation, errors = DonationService.new(params).execute

      expect(errors.empty?).to eq(true)
      expect(donation).to be_persisted
      expect(donation.user_data["email"]).to eq(params[:email])
      expect(donation.user_data["name"]).to eq(params[:name])
      expect(donation.user_data["phone_number"]).to eq(params[:phone_number])
      expect(donation.user_data["customer_ip"]).to eq(params[:customer_ip])
      expect(donation.amount.to_i).to eq(10)
      # Stripe stores the amount in cents
      expect(donation.charge_data["amount"]).to eq(donation.amount * 100)
      expect(donation.charge_data).to have_key("id")
      expect(donation.status).to eq("succeeded")
      expect(donation.customer_ip).to eq(params[:customer_ip])
    end

    it "returns error if charge is declined" do
      params = valid_params.merge({
        stripe_token: stripe_helper.generate_card_token
      })

      StripeMock.prepare_card_error(:card_declined)

      donation, errors = DonationService.new(params).execute

      expect(errors.empty?).to eq(false)
      expect(errors["base"]).to eq(["The card was declined"])
    end
  end
end
