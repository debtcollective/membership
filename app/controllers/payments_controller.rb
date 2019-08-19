# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :current_user, only: %i[new]

  def new; end

  def create
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Subscription was successfully added.' }
      format.json { render :show, status: :created, location: @subscription }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def current_user
    @user = User.find(params[:user_id])
  end
end
