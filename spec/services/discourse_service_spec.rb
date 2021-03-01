# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscourseService, type: :service do
  # set discourse env vars
  around do |example|
    ClimateControl.modify(
      DISCOURSE_URL: "http://lvh.me:3000",
      DISCOURSE_API_KEY: "EXAMPLE_API_KEY",
      DISCOURSE_USERNAME: "system"
    ) do
      example.run
    end
  end

  describe ".invite_user" do
    let(:user) { FactoryBot.create(:user) }

    it "creates a discourse invite" do
      discourse = DiscourseService.new(user)

      # stub request
      body = {
        "custom_message" => I18n.t("discourse_service.invite_custom_message"),
        "email" => user.email,
        "group_names" => ""
      }
      response = {"success": "OK"}
      stub_discourse_request(:post, "invites", body)
        .to_return(status: 200, body: response.to_json, headers: {"Content-Type": "application/json"})

      response = discourse.invite_user

      expect(response["success"]).to eq("OK")
    end
  end

  describe ".find_user_by_email" do
    let(:user) { FactoryBot.create(:user) }

    it "returns a user if account was found" do
      discourse = DiscourseService.new(user)

      # stub request
      query = {filter: user.email, order: "ascending", page: 1}.to_query
      url = "admin/users/list/active.json?#{query}"
      response = [{
        "id" => 10,
        "username" => "auser",
        "name" => "Debt Collective",
        "avatar_template" => "/user_avatar/localhost/system/{size}/2_2.png",
        "email" => "no_email",
        "secondary_emails" => [],
        "active" => true,
        "admin" => true,
        "moderator" => true,
        "last_seen_at" => nil,
        "last_emailed_at" => nil,
        "created_at" => "2020-08-05T20:33:43.254Z",
        "last_seen_age" => nil,
        "last_emailed_age" => nil,
        "created_at_age" => 4225612.914831,
        "trust_level" => 4,
        "manual_locked_trust_level" => nil,
        "flag_level" => 0,
        "title" => nil,
        "time_read" => 0,
        "staged" => false,
        "days_visited" => 0,
        "posts_read_count" => 9,
        "topics_entered" => 0,
        "post_count" => 3
      }]
      stub_discourse_request(:get, url)
        .to_return(status: 200, body: response.to_json, headers: {"Content-Type": "application/json"})

      response = discourse.find_user_by_email(email: user.email)

      expect(response).not_to be_nil
      expect(response["id"]).to eq(10)
    end

    it "returns nil if no account was found" do
      discourse = DiscourseService.new(user)

      # stub request
      query = {filter: user.email, order: "ascending", page: 1}.to_query
      url = "admin/users/list/active.json?#{query}"
      response = []
      stub_discourse_request(:get, url)
        .to_return(status: 200, body: response.to_json, headers: {"Content-Type": "application/json"})

      response = discourse.find_user_by_email(email: user.email)

      expect(response).to be_nil
    end
  end

  describe ".create_user" do
    it "creates a user with random username and password" do
      custom_fields = {
        address_city: Faker::Address.city,
        address_country_code: Faker::Address.country_code,
        address_line1: Faker::Address.street_address,
        address_zip: Faker::Address.zip_code,
        phone_number: Faker::PhoneNumber.phone_number
      }

      user = FactoryBot.create(:user, custom_fields: custom_fields)

      discourse = DiscourseService.new(user)

      response = {
        "success" => true,
        "active" => true,
        "email_token" => "15fa6c1c626cb97ccf18e5abd537260e",
        "message" =>
          "Your account is activated and ready to use.",
        "user_id" => 9,
        "username" => "orlando"
      }

      stub_discourse_request(:post, "users")
        .to_return(status: 200, body: response.to_json, headers: {"Content-Type": "application/json"})

      response = discourse.create_user

      expect(response["success"]).to eq(true)
    end

    xit "creates a user with random username and password against the API" do
      custom_fields = {
        address_city: Faker::Address.city,
        address_country_code: Faker::Address.country_code,
        address_line1: Faker::Address.street_address,
        address_zip: Faker::Address.zip_code,
        phone_number: Faker::PhoneNumber.phone_number
      }

      user = FactoryBot.create(:user, custom_fields: custom_fields)

      WebMock.allow_net_connect!

      discourse = DiscourseService.new(user)

      response = discourse.create_user

      expect(response["success"]).to eq(true)
      expect(response["email_token"]).to be_truthy

      WebMock.disable_net_connect!
    end
  end

  describe ".create_email_token" do
    it "creates a email token" do
      user = FactoryBot.create(:user)

      discourse = DiscourseService.new(user)

      response = {
        "success" => "OK",
        "user_found" => true,
        "email_token" => "15fa6c1c626cb97ccf18e5abd537260e"
      }

      stub_discourse_request(:post, "u/email-token.json")
        .to_return(status: 200, body: response.to_json, headers: {"Content-Type": "application/json"})

      response = discourse.create_email_token

      expect(response["success"]).to eq("OK")
      expect(response["user_found"]).to eq(true)
      expect(response["email_token"]).to eq("15fa6c1c626cb97ccf18e5abd537260e")
    end

    it "returns user_found false when no user is found" do
      user = FactoryBot.create(:user, email: "notfound@example.com")
      discourse = DiscourseService.new(user)

      response = {
        "success" => "OK",
        "user_found" => false,
        "email_token" => nil
      }

      stub_discourse_request(:post, "u/email-token.json", {login: user.email})
        .to_return(status: 200, body: response.to_json, headers: {"Content-Type": "application/json"})

      response = discourse.create_email_token

      expect(response["success"]).to eq("OK")
      expect(response["user_found"]).to eq(false)
      expect(response["email_token"]).to be_falsy
    end

    it "creates an email token" do
      user = FactoryBot.create(:user, email: "orlando@debtcollective.org")

      response = {
        "success" => "OK",
        "user_found" => true,
        "email_token" => "29fa89dd95e1f5008fbad2b3fca9011e"
      }

      stub_discourse_request(:post, "u/email-token.json", {login: user.email})
        .to_return(status: 200, body: response.to_json, headers: {"Content-Type": "application/json"})

      discourse = DiscourseService.new(user)
      response = discourse.create_email_token

      expect(response["success"]).to eq("OK")
      expect(response["user_found"]).to eq(true)
      expect(response["email_token"]).to be_truthy
    end

    xit "creates a email token against the API" do
      user = FactoryBot.create(:user, email: "orlando@debtcollective.org")

      WebMock.allow_net_connect!

      discourse = DiscourseService.new(user)
      response = discourse.create_email_token

      expect(response["success"]).to eq("OK")
      expect(response["user_found"]).to eq(true)
      expect(response["email_token"]).to be_truthy

      WebMock.disable_net_connect!
    end
  end
end
