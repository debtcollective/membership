class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    # TODO: find a better way to do this
    @user = User.find_by(email: "user_mailer_welcome_email_preview@example.com")
    @user ||= FactoryBot.create(:user_with_subscription, email: "user_mailer_welcome_email_preview@example.com")

    UserMailer.welcome_email(user: @user)
  end

  def confirmation_email
    @user = User.new(name: "Betsy DeVos", email: "betsy.devos@ed.gov", confirmation_token: SecureRandom.hex(20))

    UserMailer.confirmation_email(user: @user)
  end
end
