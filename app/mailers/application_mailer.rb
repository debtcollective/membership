class ApplicationMailer < ActionMailer::Base
  default from: ENV["EMAIL_FROM"] || "no-reply@debtcollective.org"

  layout "mailer"
end
