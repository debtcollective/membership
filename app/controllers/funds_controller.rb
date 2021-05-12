class FundsController < ApplicationController
  FUNDS_CACHE_KEY = "funds/index.json"

  def index
    funds_json = Rails.cache.fetch(FUNDS_CACHE_KEY) { Fund.all.to_json }

    respond_to do |format|
      format.json { render json: funds_json, status: :ok }
    end
  end
end
