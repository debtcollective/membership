# frozen_string_literal: true

class UserProfilesController < ApplicationController
  before_action :authenticate_user!, only: :update

  def edit
    @user_profile = current_user.find_or_create_user_profile
  end

  def update
    @user_profile = current_user.find_or_create_user_profile
    @user_profile.assign_attributes(user_profile_params)

    respond_to do |format|
      if @user_profile.save
        format.html do
          flash[:success] = "Profile updated"

          render :edit
        end
      else
        format.html do
          flash[:error] = "There were errors updating your profile"

          render :edit
        end
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
