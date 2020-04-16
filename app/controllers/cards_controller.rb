# frozen_string_literal: true

class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  # GET /user/1/cards
  # GET /user/1/cards.json
  def index
    @cards = @user.cards
  end

  # DELETE /user/1/card/1
  # DELETE /user/1/card/1.json
  def destroy; end

  private

  def set_user
    @user = current_user
  end
end
