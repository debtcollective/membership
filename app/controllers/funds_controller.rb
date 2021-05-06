class FundsController < ApplicationController
  def index
    funds = Rails.cache.fetch("all_funds", expires_in: 24.hours) { Fund.all }

    respond_to do |format|
      format.json { render json: funds, status: :ok }
    end
  end
end
