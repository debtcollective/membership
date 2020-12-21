# frozen_string_literal: true

class AddLocationDataToUserProfileJob < ApplicationJob
  queue_as :default

  def perform(user_id:)
    user = User.find(user_id)

    add_user_location_data(user)
  end

  def add_user_location_data(user)
    zip_code = user.custom_fields["address_zip"]
    country_code = user.custom_fields["address_country_code"]

    location = AlgoliaPlacesClient.query(zip_code, {countries: [country_code]})
    return if location.nil?

    user.custom_fields["address_state"] = location["state"]
    user.custom_fields["address_county"] = location["county"]
    user.custom_fields["address_geoloc"] = location["geoloc"]

    user.save
  end
end
