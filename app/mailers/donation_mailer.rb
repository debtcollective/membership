class DonationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.donation_mailer.thank_you_email.subject
  #
  def thank_you_email(params)
    # first and last name
    # donation amount
    # donation description
    # donation id
    # donation date
    # payment type
    @user = params[:user]
    @donation = params[:donation]

    # email
    email = @user&.email || @donation.user_data["email"]

    mail to: email
  end
end
