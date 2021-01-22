# frozen_string_literal: true

class AlgoliaDegradedQueryError < StandardError; end

class AddLocationDataToUserProfileJob < ApplicationJob
  queue_as :default
  retry_on AlgoliaDegradedQueryError, wait: 4.hours, attempts: 2

  def perform(user_id:)
    user = User.find(user_id)

    add_user_location_data(user)
  end

  def add_user_location_data(user)
    zip_code = user.custom_fields["address_zip"]
    country_code = user.custom_fields["address_country_code"].downcase

    location = AlgoliaPlacesClient.query(zip_code, {countries: [country_code]})

    if location["degraded_query"]
      raise AlgoliaDegradedQueryError
    end

    return if location.nil?

    user.custom_fields["address_state"] = location["state"]
    user.custom_fields["address_county"] = location["county"]
    user.custom_fields["address_geoloc"] = location["geoloc"]

    user.save
  end
end
