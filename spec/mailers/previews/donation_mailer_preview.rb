class DonationMailerPreview < ActionMailer::Preview
  def thank_you_email
    DonationMailer.with(user: User.first).thank_you_email
  end
end
