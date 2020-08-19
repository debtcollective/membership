class DonationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.donation_mailer.thank_you_email.subject
  #
  def thank_you_email
    # donation amount
    # donation description
    # donation id
    # donation date
    # payment type
    # first and last name
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
