# frozen_string_literal: true

class SubscribeUserToNewsletterJob < ApplicationJob
  queue_as :default

  def perform(user_id:, tags: [], debug: true)
    api_key = ENV["MAILCHIMP_API_KEY"]
    list_id = ENV["MAILCHIMP_LIST_ID"]

    return unless api_key.present? && list_id.present?

    user = User.find(user_id)
    email = user.email
    customer_ip = user.custom_fields["customer_ip"]
    phone_number = user.phone_number

    gibbon = Gibbon::Request.new(api_key: api_key, debug: debug)
    email_digest = Digest::MD5.hexdigest(email)

    newsletter_params = {
      email_address: email,
      status: "subscribed",
      ip_signup: customer_ip,
      merge_fields: {
        FNAME: user.first_name,
        LNAME: user.last_name
      }
    }

    # TODO: validation until we implement a better one on the union widget/membership controller
    #   Mailchimp fails if the phone number is not valid
    if phone_number.length >= 8
      newsletter_params[:merge_fields][:PHONE] = phone_number
    end

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
  rescue Gibbon::MailChimpError => e
    Raven.capture_exception(e)
  end
end
