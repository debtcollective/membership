# frozen_string_literal: true

require "rails_helper"

RSpec.describe MembershipService, type: :service do
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:valid_params) do
    {
      address_city: Faker::Address.city,
      address_country_code: Faker::Address.country_code,
      address_line1: Faker::Address.street_address,
      address_zip: Faker::Address.zip_code,
      amount: 10,
      customer_ip: "127.0.0.1",
      email: Faker::Internet.email,
      name: Faker::Name.name,
      phone_number: Faker::PhoneNumber.phone_number,
      stripe_token: stripe_helper.generate_card_token
    }
  end

  before { StripeMock.start }
  after { StripeMock.stop }

  describe "validations" do
    subject { MembershipService.new(valid_params) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).only_integer.is_greater_than_or_equal_to(5) }
    it { should validate_presence_of(:customer_ip) }
    it { should validate_presence_of(:phone_number) }
    it { should validate_presence_of(:stripe_token) }
    it { should validate_presence_of(:address_line1) }
    it { should validate_presence_of(:address_city) }
    it { should validate_presence_of(:address_zip) }
    it { should validate_presence_of(:address_country_code) }
    it { should validate_presence_of(:stripe_token) }

    context "when amount is zero" do
      subject { MembershipService.new(valid_params.merge(amount: 0)) }

      it { should validate_presence_of(:amount) }
      it { should validate_numericality_of(:amount).only_integer }
      it { should_not validate_presence_of(:stripe_token) }
    end
  end

  describe ".execute" do
    let(:user) { FactoryBot.create(:user) }

    it "creates a subscription and updates user custom_fields" do
      params = valid_params.merge({
        stripe_token: stripe_helper.generate_card_token
      })

      subscription, errors = MembershipService.new(params, user).execute
      donation = subscription.donations.first

      expect(errors.empty?).to eq(true)
      expect(donation).to be_persisted
      expect(donation.amount.to_i).to eq(10)
      # Stripe stores the amount in cents
      expect(donation.charge_data["amount"]).to eq(donation.amount * 100)
      expect(donation.status).to eq("succeeded")

      expect(subscription.active).to eq(true)
      expect(subscription.amount).to eq(10)

      user.reload

      expect(user.custom_fields["address_city"]).to eq(params[:address_city])
      expect(user.custom_fields["address_zip"]).to eq(params[:address_zip])
    end

    it "creates a user if not provided" do
      params = valid_params.merge({
        email: "newuser@example.com",
        stripe_token: stripe_helper.generate_card_token
      })

      subscription, errors = MembershipService.new(params).execute
      user = subscription.user
      donation = user.donations.last

      expect(errors.empty?).to eq(true)
      expect(donation).to be_persisted
      expect(donation.amount.to_i).to eq(10)
      # Stripe stores the amount in cents
      expect(donation.charge_data["amount"]).to eq(donation.amount * 100)
      expect(donation.status).to eq("succeeded")

      expect(user.email).to eq(params[:email])
      expect(user.custom_fields["address_city"]).to eq(params[:address_city])

      expect(subscription.user).to eq(user)
      expect(subscription.active).to eq(true)
      expect(subscription.amount).to eq(10)
      expect(subscription.last_charge_at).to be_within(1.second).of DateTime.now
    end

    it "creates a membership without charging a card if amount is 0" do
      params = valid_params.merge({
        email: "newuser@example.com",
        amount: 0,
        stripe_token: nil
      })

      subscription, errors = MembershipService.new(params).execute
      user = subscription.user
      donation = subscription.donations.last

      expect(errors.empty?).to eq(true)

      expect(user.email).to eq(params[:email])
      expect(user.custom_fields["address_city"]).to eq(params[:address_city])

      expect(subscription.user).to eq(user)
      expect(subscription.active).to eq(true)
      expect(subscription.amount).to eq(0)
      expect(subscription.last_charge_at).to eq(nil)

      expect(donation).to eq(nil)
    end

    it "recreates stripe user if we the stripe_id is invalid" do
      user = FactoryBot.create(:user, stripe_id: "invalid-stripe-id")

      params = valid_params.merge({
        stripe_token: stripe_helper.generate_card_token
      })

      subscription, errors = MembershipService.new(params, user).execute
      user.reload

      expect(errors.empty?).to eq(true)

      expect(user.stripe_id).not_to eq("invalid-stripe-id")
      expect(subscription.user).to eq(user)
      expect(subscription.active).to eq(true)
      expect(subscription.amount).to eq(10)
    end

    it "returns error if user has a subscription" do
      # active subscription
      FactoryBot.create(:subscription, user: user)

      params = valid_params.merge({
        email: user.email
      })

      new_subscription, errors = MembershipService.new(params).execute

      expect(new_subscription.persisted?).to eq(false)
      expect(errors["base"]).to eq([I18n.t("subscription.errors.active_subscription")])
    end

    it "returns error if charge is declined" do
      params = valid_params.merge({
        stripe_token: stripe_helper.generate_card_token
      })

      StripeMock.prepare_card_error(:card_declined)

      subscription, errors = MembershipService.new(params, user).execute

      expect(subscription.persisted?).to eq(false)
      expect(errors.empty?).to eq(false)
      expect(errors["base"]).to eq(["The card was declined"])
    end
  end
end
