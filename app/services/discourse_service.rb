class DiscourseService
  attr_reader :user, :client

  def initialize(user)
    @user = user

    @client = DiscourseApi::Client.new(ENV["DISCOURSE_URL"])
    @client.api_key = ENV["DISCOURSE_API_KEY"]
    @client.api_username = ENV["DISCOURSE_USERNAME"]
  end

  # Invite user via email
  def invite_user
    client.invite_user({
      email: user.email,
      group_names: "",
      custom_message: I18n.t("discourse_service.invite_custom_message")
    })
  end

  # Find user by email
  #
  # email - String - valid email
  #
  # Returns the User or nil if no user was found
  def find_user_by_email(email: user&.email)
    users = client.list_users("active", {
      filter: email,
      order: "ascending",
      page: 1
    })

    users.first
  end
end
