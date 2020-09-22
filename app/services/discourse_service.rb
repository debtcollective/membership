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
      custom_message: "Welcome to the Debt Collective! We are thrilled to have you with us."
    })
  end

  # Find user by email
  #
  # email - String - valid email
  #
  # Returns the User or nil if no user was found
  def find_user_by_email(email:)
    users = client.list_users("active", {
      filter: email,
      show_emails: false,
      order: "ascending",
      page: 1
    })

    users.first
  end
end
