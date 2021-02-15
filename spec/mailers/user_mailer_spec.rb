require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "notify" do
    let(:user) { FactoryBot.create(:user, email_token: "test-token") }
    let(:mail) { UserMailer.welcome_email(user: user) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("user_mailer.welcome_email.suject"))
      expect(mail.to).to eq(user.email)
      expect(mail.from).to eq(ENV["MAIL_FROM"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end
end
