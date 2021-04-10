# frozen_string_literal: true

class UserMissingStateError < StandardError; end

class SubscribeUserToNewsletterJob < ApplicationJob
  queue_as :mailers
  retry_on UserMissingStateError, wait: 5.minutes, attempts: 2

  def perform(user_id:, tags: [], debug: true)
    api_key = ENV["MAILCHIMP_API_KEY"]
    list_id = ENV["MAILCHIMP_LIST_ID"]

    return unless api_key.present? && list_id.present?

    user = User.find(user_id)
    email = user.email
    customer_ip = user.custom_fields["customer_ip"]

    # We need the user to have the State field in their profile for this not to fail
    # We are getting this from Algolia, but I think we need to add this field to the membership widget
    #
    # Here we raise an error on the first execution if the address is missing
    # TODO: remove this code when we ask for the state on the membership widget
    address_state = user.custom_fields["address_state"]
    raise UserMissingStateError if address_state.blank? && executions == 1

    gibbon = Gibbon::Request.new(api_key: api_key, debug: debug)
    email_digest = Digest::MD5.hexdigest(email)

    newsletter_params = {
      email_address: email,
      status: "subscribed",
      ip_signup: customer_ip,
      merge_fields: merge_fields(user)
    }

    gibbon
      .lists(list_id)
      .members(email_digest)
      .upsert(body: newsletter_params)

    if tags.any?
      gibbon
        .lists(list_id)
        .members(email_digest)
        .tags
        .create(body: {
          tags: tags
        })
    end

    user.custom_fields["subscribed_to_newsletter"] = true

    user.save
  rescue Gibbon::MailChimpError => e
    Raven.capture_exception(e)
  end

  def merge_fields(user)
    merge_fields_hash = {
      FNAME: user.first_name,
      LNAME: user.last_name
    }

    # Address merge field has a specific schema
    # https://us1.api.mailchimp.com/schema/3.0/Lists/Members/MergeField.json
    custom_fields = user.custom_fields
    address_keys = [:addr1, :city, :country, :state, :zip]
    address = {
      addr1: custom_fields["address_line1"],
      city: custom_fields["address_city"],
      country: custom_fields["address_country_code"],
      state: custom_fields["address_state"],
      zip: custom_fields["address_zip"]
    }

    valid_address = address_keys.all? { |key| address[key].present? }
    if valid_address
      merge_fields_hash[:ADDRESS] = address
    end

    # TODO: validation until we implement a better one on the union widget/membership controller
    # Mailchimp fails if the phone number is not valid
    phone_number = user.phone_number
    if phone_number&.length.to_i >= 7 && phone_number&.length.to_i <= 15
      merge_fields_hash[:PHONE] = phone_number
    end

    merge_fields_hash
  end
end
