# frozen_string_literal: true

class Admin::DonationsController < ApplicationController
  before_action :set_donation, only: %i[show]

  # GET /admin/donations
  # GET /admin/donations.json
  def index
    @donations = Donation.all
  end

  # GET /admin/donations/1
  # GET /admin/donations/1.json
  def show; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_donation
    @donation = Donation.find(params[:id])
  end
end
