class DonationMailerPreview < ActionMailer::Preview
  def thank_you_email
    @donation = Donation.last

    DonationMailer.thank_you_email(donation: @donation)
  end
end
