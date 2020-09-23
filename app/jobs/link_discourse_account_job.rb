# frozen_string_literal: true

class LinkDiscourseAccountJob < ApplicationJob
  queue_as :default

  def perform(user)
    discourse = DiscourseService.new(user)

    # Find Discourse User
    discourse_user = discourse.find_user_by_email

    # If there's a Discourse user, send verification email
    if discourse_user
      # TODO: implement verification email to a membership with a Discourse account
      user.update(external_id: discourse_user["id"])
      return
    end

    # Invite user to create a Discourse account
    response = discourse.invite_user

    if response["success"] != "OK"
      Raven.capture_message(
        "Couldn't create a Discourse invite",
        extra: {user_id: user.id, user_email: user.email}
      )
    end
  end
end
