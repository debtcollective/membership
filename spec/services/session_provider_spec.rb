# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionProvider, type: :service do
  describe "#current_user" do
    it "reads cookie and returns current_user" do
      ClimateControl.modify(SSO_COOKIE_NAME: "tdc_auth_cookie", SSO_JWT_SECRET: "jwt-secret") do
        payload = JSON.parse(file_fixture("jwt_sso_payload.json").read)
        jwt = JWT.encode(payload, ENV["SSO_JWT_SECRET"], "HS256")
        cookie_name = ENV["SSO_COOKIE_NAME"]
        cookies = {}
        cookies[cookie_name] = jwt
        session = {}

        current_user = SessionProvider.new(cookies, session).current_user

        expect(current_user.external_id).to eql(1)
      end
    end

    it "returns user from session if cookies are not available" do
      ClimateControl.modify(SSO_COOKIE_NAME: "tdc_auth_cookie", SSO_JWT_SECRET: "jwt-secret") do
        user = FactoryBot.create(:user)
        cookies = {}
        session = {user_id: user.id}

        current_user = SessionProvider.new(cookies, session).current_user

        expect(current_user.id).to eql(user.id)
      end
    end

    it "returns nil if no user was found" do
      ClimateControl.modify(SSO_COOKIE_NAME: "tdc_auth_cookie", SSO_JWT_SECRET: "jwt-secret") do
        cookies = {}
        session = {}

        current_user = SessionProvider.new(cookies, session).current_user

        expect(current_user).to be_nil
      end
    end

    it "cleans up user session if there's a cookie based session" do
      ClimateControl.modify(SSO_COOKIE_NAME: "tdc_auth_cookie", SSO_JWT_SECRET: "jwt-secret") do
        user = FactoryBot.create(:user)
        payload = JSON.parse(file_fixture("jwt_sso_payload.json").read)
        jwt = JWT.encode(payload, ENV["SSO_JWT_SECRET"], "HS256")
        cookie_name = ENV["SSO_COOKIE_NAME"]
        cookies = {}
        cookies[cookie_name] = jwt
        session = {user_id: user.id}

        current_user = SessionProvider.new(cookies, session).current_user

        expect(current_user.external_id).to eql(1)
        expect(session[:user_id]).to be_nil
      end
    end
  end
end
