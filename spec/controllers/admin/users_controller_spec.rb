# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:valid_attributes) { FactoryBot.attributes_for(:user) }

  let(:invalid_attributes) { { email: 'foo@bar.com', country: 'Spain' } }

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'returns a success response' do
      User.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end
end
