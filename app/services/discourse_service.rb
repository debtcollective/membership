class DiscourseService
  attr_reader :user, :client

  def initialize(user)
    @user = user

    @client = DiscourseApi::Client.new(ENV["DISCOURSE_URL"])
    @client.api_key = ENV["DISCOURSE_API_KEY"]
    @client.api_username = ENV["DISCOURSE_USERNAME"]
  end

  # Invite user via email
  def invite_by_email(email:)
  end

  # Find user by email
  #
  # email - String - valid email
  def find_user_by_email(email:)
    users = client.list_users("active", {
      filter: email,
      show_emails: false,
      order: "ascending",
      page: 1
    })

    return users.first if users.any?
  end
end
