class MembershipMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.membership_mailer.payment_failure_email.subject
  #
  default from: ENV["MAIL_FROM"]

  def payment_failure_email(user:)
    @user = user
    email = @user.email

    mail to: email, from: ENV["MAIL_FROM"]
  end
end
