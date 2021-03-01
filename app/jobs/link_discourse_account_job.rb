# frozen_string_literal: true

class LinkDiscourseAccountJob < ApplicationJob
  queue_as :default

  def perform(user)
    discourse = DiscourseService.new(user)

    # If user has external_id, skip
    return if user.external_id

    # Find Discourse User
    discourse_user = discourse.find_user_by_email

    if discourse_user
      user.external_id = discourse_user["id"]
      user.username = discourse_user["username"]

      response = discourse.create_email_token

      if [true, "OK"].exclude?(response["success"])
        return Raven.capture_message(
          "Couldn't create a Discourse invite",
          extra: {user_id: user.id, user_email: user.email}
        )
      end

      user.email_token = response["email_token"]
    else
      # Create discourse account
      response = discourse.create_user

      if [true, "OK"].exclude?(response["success"])
        return Raven.capture_message(
          "Couldn't create a Discourse invite",
          extra: {user_id: user.id, user_email: user.email}
        )
      end

      user.email_token = response["email_token"]
      user.external_id = response["user_id"]
      user.username = response["username"]
    end

    user.save!
    logger.info("Discourse account #{response["user_id"]} linked with user id #{user.id}")

    user.send_welcome_email
  end
end
