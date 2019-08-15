# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::PlansController, type: :controller do
  let(:valid_attributes) do
    FactoryBot.attributes_for(:plan)
  end

  let(:invalid_attributes) do
    { name: 'gibberish', amount: 'number' }
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

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      plan = Plan.create! valid_attributes
      get :edit, params: { id: plan.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Plan' do
        expect do
          post :create, params: { plan: valid_attributes }, session: valid_session
        end.to change(Plan, :count).by(1)
      end

      it 'redirects to the created plan' do
        post :create, params: { plan: valid_attributes }, session: valid_session
        expect(response).to redirect_to(admin_plan_url(Plan.last))
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { plan: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        FactoryBot.attributes_for(:plan)
      end

      it 'updates the requested plan' do
        plan = Plan.create! valid_attributes
        put :update, params: { id: plan.to_param, plan: new_attributes }, session: valid_session
        plan.reload
        expect(plan.name).to eq(new_attributes[:name])
        expect(plan.description).to eq(new_attributes[:description])
        expect(plan.amount).to eq(new_attributes[:amount])
      end

      it 'redirects to the plan' do
        plan = Plan.create! valid_attributes
        put :update, params: { id: plan.to_param, plan: valid_attributes }, session: valid_session
        expect(response).to redirect_to(admin_plan_url(plan))
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'edit' template)" do
        plan = Plan.create! valid_attributes
        put :update, params: { id: plan.to_param, plan: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested plan' do
      plan = Plan.create! valid_attributes
      expect do
        delete :destroy, params: { id: plan.to_param }, session: valid_session
      end.to change(Plan, :count).by(-1)
    end

    it 'redirects to the plans list' do
      plan = Plan.create! valid_attributes
      delete :destroy, params: { id: plan.to_param }, session: valid_session
      expect(response).to redirect_to(admin_plans_url)
    end
  end
end
