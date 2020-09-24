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
    response = client.invite_user({
      email: user.email,
      group_names: "",
      custom_message: "Welcome to the Debt Collective! With this account you will be able to authenticate to all of our services. Please click on Accept invite to complete your registration process"
    })

    JSON.parse(response)
  end

  # Find user by email
  #
  # email - String - valid email
  #
  # Returns the User or nil if no user was found
  def find_user_by_email(email: user&.email)
    response = client.list_users("active", {
      filter: email,
      order: "ascending",
      page: 1
    })

    users = JSON.parse(response)

    users.first
  end
end
