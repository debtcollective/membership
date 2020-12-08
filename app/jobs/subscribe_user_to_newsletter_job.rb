# frozen_string_literal: true

class SubscribeUserToNewsletterJob < ApplicationJob
  queue_as :default

  def perform(user_id:, tags: [], debug: true)
    api_key = ENV["MAILCHIMP_API_KEY"]
    list_id = ENV["MAILCHIMP_LIST_ID"]

    user = User.find(user_id)
    email = user.email
    customer_ip = user.custom_fields["customer_ip"]

    gibbon = Gibbon::Request.new(api_key: api_key, debug: debug)
    email_digest = Digest::MD5.hexdigest(email.downcase)

    gibbon
      .lists(list_id)
      .members(email_digest)
      .upsert(body: {
        email_address: email,
        status: "subscribed",
        ip_signup: customer_ip,
        merge_fields: {
          FNAME: user.first_name,
          LNAME: user.last_name,
          PHONE: user.phone_number
        }
      })

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
