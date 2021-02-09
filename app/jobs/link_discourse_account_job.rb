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
      if user.confirmed?
        user.update(external_id: discourse_user["id"])
      else
        # send confirmation email
        User.send_confirmation_instructions(email: user.email)
      end

      return
    end

    # Create discourse account
    response = discourse.create_user

    if response["success"] != "OK"
      Raven.capture_message(
        "Couldn't create a Discourse invite",
        extra: {user_id: user.id, user_email: user.email}
      )
    end
  end
end
