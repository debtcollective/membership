# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let!(:admin) { FactoryBot.create(:user, admin: true) }
  let(:valid_attributes) { FactoryBot.attributes_for(:user) }
  let(:invalid_attributes) { {email: "foo", country: "Spain"} }
  let(:valid_session) { {} }

  before(:each) do
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(admin)
  end

  describe "GET #index" do
    it "returns a success response" do
      User.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      user = User.create! valid_attributes
      get :show, params: {id: user.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      user = User.create! valid_attributes
      get :edit, params: {id: user.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        FactoryBot.attributes_for(:user)
      end

      it "updates the requested user" do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: {name: new_attributes[:name], email: new_attributes[:email]}}, session: valid_session
        user.reload
        expect(user.email).to eq(new_attributes[:email])
        expect(user.name).to eq(new_attributes[:name])
      end

      it "redirects to the user" do
        user = User.create! valid_attributes
        put :update, params: {id: user.to_param, user: valid_attributes}, session: valid_session
        expect(response).to redirect_to(admin_user_path(user))
      end
    end
  end
end
