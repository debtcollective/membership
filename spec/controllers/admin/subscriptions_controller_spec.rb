# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SubscriptionsController, type: :controller do
  let!(:admin) { FactoryBot.create(:user, admin: true) }
  let(:user) { FactoryBot.create(:user) }
  let(:plan) { FactoryBot.create(:plan) }
  let(:valid_attributes) do
    FactoryBot.attributes_for(:subscription, user_id: user.id, plan_id: plan.id)
  end

  let(:invalid_attributes) do
    { name: 'gibberish', amount: 'number' }
  end

  let(:valid_session) { {} }

  before(:each) do
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(admin)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Subscription.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      subscription = Subscription.create! valid_attributes
      get :show, params: { id: subscription.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      subscription = Subscription.create! valid_attributes
      get :edit, params: { id: subscription.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:subscription) { FactoryBot.create(:subscription, active: false) }
      let(:new_attributes) do
        { active: true }
      end

      it 'updates the requested subscription' do
        put :update, params: { id: subscription.to_param, subscription: new_attributes }, session: valid_session
        subscription.reload
        expect(subscription.active).to eq(new_attributes[:active])
      end

      it 'redirects to the subscription' do
        put :update, params: { id: subscription.to_param, subscription: new_attributes }, session: valid_session
        subscription.reload
        expect(response).to redirect_to(admin_subscription_url(subscription))
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested subscription' do
      subscription = Subscription.create! valid_attributes
      expect do
        delete :destroy, params: { id: subscription.to_param }, session: valid_session
      end.to change(Subscription, :count).by(-1)
    end

    it 'redirects to the subscriptions list' do
      subscription = Subscription.create! valid_attributes
      delete :destroy, params: { id: subscription.to_param }, session: valid_session
      expect(response).to redirect_to(admin_subscriptions_url)
    end
  end
end
