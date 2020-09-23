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
        "custom_message": "Welcome to the Debt Collective! We are thrilled to have you with us.",
        "email": user.email,
        "group_names": ""
      }
      response = {"success": "OK"}
      stub_discourse_request(:post, "invites", body)
        .to_return(status: 200, body: response.to_json, headers: {})

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
        "id": 10,
        "username": "auser",
        "name": "Debt Collective",
        "avatar_template": "/user_avatar/localhost/system/{size}/2_2.png",
        "email": "no_email",
        "secondary_emails": [],
        "active": true,
        "admin": true,
        "moderator": true,
        "last_seen_at": nil,
        "last_emailed_at": nil,
        "created_at": "2020-08-05T20:33:43.254Z",
        "last_seen_age": nil,
        "last_emailed_age": nil,
        "created_at_age": 4225612.914831,
        "trust_level": 4,
        "manual_locked_trust_level": nil,
        "flag_level": 0,
        "title": nil,
        "time_read": 0,
        "staged": false,
        "days_visited": 0,
        "posts_read_count": 9,
        "topics_entered": 0,
        "post_count": 3
      }]
      stub_discourse_request(:get, url)
        .to_return(status: 200, body: response.to_json, headers: {})

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
        .to_return(status: 200, body: response.to_json, headers: {})

      response = discourse.find_user_by_email(email: user.email)

      expect(response).to be_nil
    end
  end

end
