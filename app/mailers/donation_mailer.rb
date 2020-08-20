class DonationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.donation_mailer.thank_you_email.subject
  #
  def thank_you_email(donation:)
    @donation = donation
    email = @donation.contributor_email

    mail to: email
  end
end
