class MembershipMailerPreview < ActionMailer::Preview
  def payment_failure_email
    # TODO: find a better way to do this
    @user = User.first

    MembershipMailer.payment_failure_email(user: @user)
  end
end
