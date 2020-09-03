# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::FundsController, type: :controller do
  let!(:admin) { FactoryBot.create(:user, admin: true) }
  let(:valid_attributes) do
    FactoryBot.attributes_for(:fund)
  end

  let(:valid_session) { {} }

  before(:each) do
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(admin)
  end

  describe "GET #index" do
    it "returns a success response" do
      Fund.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      fund = Fund.create! valid_attributes
      get :edit, params: {id: fund.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Fund" do
        expect {
          post :create, params: {fund: valid_attributes}, session: valid_session
        }.to change(Fund, :count).by(1)
      end

      it "redirects to the index after creating fund" do
        post :create, params: {fund: valid_attributes}, session: valid_session
        expect(response).to redirect_to(admin_funds_url)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        FactoryBot.attributes_for(:fund)
      end

      it "updates the requested fund" do
        fund = Fund.create! valid_attributes
        put :update, params: {id: fund.to_param, fund: new_attributes}, session: valid_session
        fund.reload
        expect(fund.name).to eq(new_attributes[:name])
        expect(fund.slug).to eq(new_attributes[:slug])
      end

      it "redirects to the funds list" do
        fund = Fund.create! valid_attributes
        put :update, params: {id: fund.to_param, fund: valid_attributes}, session: valid_session
        expect(response).to redirect_to(admin_funds_url)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested fund" do
      fund = FactoryBot.create(:fund)

      expect {
        delete :destroy, params: {id: fund.to_param}, session: valid_session
      }.to change(Fund, :count).by(-1)
    end

    it "redirects to the Funds list" do
      fund = FactoryBot.create(:fund)

      delete :destroy, params: {id: fund.to_param}, session: valid_session
      expect(response).to redirect_to(admin_funds_url)
    end

    it "returns an error when trying to delete funds with donations" do
      fund = FactoryBot.create(:fund)
      FactoryBot.create(:donation, fund: fund)

      expect {
        delete :destroy, params: {id: fund.to_param}, session: valid_session
      }.to change(Fund, :count).by(0)
    end
  end
end
