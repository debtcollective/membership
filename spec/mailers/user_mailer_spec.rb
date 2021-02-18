require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "notify" do
    let(:user) { FactoryBot.create(:user, email_token: "test-token") }
    let!(:mail) { UserMailer.welcome_email(user: user) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("user_mailer.welcome_email.subject"))
      expect(mail.to).to include(user.email)
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Welcome to the Debt Collective!")
    end
  end
end
