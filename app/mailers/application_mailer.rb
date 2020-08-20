class ApplicationMailer < ActionMailer::Base
  default from: ENV["EMAIL_FROM"] || "no-reply@debtcollective.org"

  helper :application
  layout "mailer"
end
