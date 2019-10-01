# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_attributes) { FactoryBot.attributes_for(:user) }

  let(:valid_session) { {} }

  describe 'GET #show' do
    it 'returns a success response' do
      user = User.create! valid_attributes
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
      get :show, params: { id: user.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end
end
