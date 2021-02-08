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

  def create_user
    # .required(:name, :email, :password, :username)
    # .optional(:active, :approved, :staged, :user_fields)
    client.create_user({
      name: user.name,
      email: user.email,
      password: SecureRandom.hex(rand(20...24)),
      username: suggest_username()
    })
  end

  # Check if username is available
  def check_username(username)
    client.check_username(username)
  end

  def suggest_username(name: user&.name, email: user&.email)
    # TODO: check if there's an API endpoint for this, and open it up maybe?
    SecureRandom.hex(rand(20...24))
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
