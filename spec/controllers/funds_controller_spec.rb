# frozen_string_literal: true

require "rails_helper"

RSpec.describe FundsController, type: :controller do
  describe "GET #index" do
    context "json" do
      let!(:default_fund) { FactoryBot.create(:fund, slug: Fund::DEFAULT_SLUG) }

      before(:each) do
        request.accept = "application/json"
      end

      it "returns a list of funds" do
        get :index

        json = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(json.count).to eq(1)
      end

      it "it returns new funds after cahe is in place", caching: true do
        # do first request to populate cache
        get :index
        json = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(json.count).to eq(1)

        # create a new fund and do a second request
        fund = FactoryBot.create(:fund, slug: "not_cached")
        get :index
        json = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(json.count).to eq(2)
        expect(json.select { |f| f["slug"] == fund.slug }).not_to be_empty
      end
    end
  end
end
