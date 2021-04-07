# frozen_string_literal: true

class UserProfilesController < ApplicationController
  before_action :authenticate_user!, only: :update

  def current
    respond_to do |format|
      if current_user.present?
        format.json { render json: current_user.as_json, status: :ok }
      else
        format.json { render json: nil, status: :not_found }
      end
    end
  end

  def update
    user_profile = current_user.user_profile

    respond_to do |format|
      if user_profile.update(user_profile_params)
        format.json { render json: user_profile.as_json, status: :ok }
      else
        format.json { render json: {errors: user_profile.errors}, status: :unprocessable_entity }
      end
    end
  end

  def user_profile_params
    params.require(:user_profile).permit(
      :title,
      :first_name,
      :last_name,
      :birthday,
      :phone_number,
      :address_line1,
      :address_line2,
      :address_city,
      :address_state,
      :address_zip,
      :address_country,
      :address_country_code,
      :facebook,
      :twitter,
      :instagram,
      :website
    )
  end
end
