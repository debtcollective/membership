# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlansController, type: :controller do
  let(:valid_attributes) do
    FactoryBot.attributes_for(:plan)
  end

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'returns a success response' do
      Plan.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      plan = Plan.create! valid_attributes
      get :show, params: { id: plan.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end
end
