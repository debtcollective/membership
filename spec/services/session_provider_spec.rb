# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionProvider, type: :service do
  describe '#current_user' do
    it 'reads cookie and returns current_user' do
      ClimateControl.modify(SSO_COOKIE_NAME: 'tdc_auth_cookie', SSO_JWT_SECRET: 'jwt-secret') do
        payload = JSON.parse(file_fixture('jwt_sso_payload.json').read)
        jwt = JWT.encode(payload, ENV['SSO_JWT_SECRET'], 'HS256')
        cookie_name = ENV['SSO_COOKIE_NAME']
        cookies = {}
        cookies[cookie_name] = jwt

        current_user = SessionProvider.new(cookies).current_user

        expect(current_user.external_id).to eql(1)
      end
    end
  end
end
