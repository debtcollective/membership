# frozen_string_literal: true

require "rails_helper"

describe "Donations", type: :feature do
  let!(:default_fund) { FactoryBot.create(:fund, name: "Debt Collective Fund", slug: Fund::DEFAULT_SLUG) }

  it "sets fund via url parameter" do
    fund = FactoryBot.create(:fund, slug: "anti-eviction", name: "Anti-Eviction Fund")
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(nil)
    visit "/donate?fund=#{fund.slug}"

    expect(page).to_not have_field("fund-#{default_fund.slug}", checked: true)
    expect(page).to have_field("fund-#{fund.slug}", checked: true)
  end

  it "sets default fund as checked if fund parameter is missing" do
    fund = FactoryBot.create(:fund, slug: "anti-eviction", name: "Anti-Eviction Fund")
    allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(nil)
    visit "/donate"

    expect(page).to have_field("fund-#{default_fund.slug}", checked: true)
    expect(page).to_not have_field("fund-#{fund.slug}", checked: true)
  end

  context "as user", js: true do
    let!(:user) { FactoryBot.create(:user, stripe_id: nil) }

    it "allows going through the flow and donate successfully" do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
      visit "/"
      expect(page).to_not have_content("Log In") # checking user is logged in
      expect(page).to have_content("Pay what you can")

      click_link "one-time-donation"

      expect(page).to have_content(I18n.t("charge.new.title"))

      within "#payment-form" do
        fill_stripe_elements(card: "4242424242424242")
        fill_in "name-field", with: Faker::Name.name
        fill_in "email-field", with: Faker::Internet.email
        fill_in "phone-number-field", with: Faker::PhoneNumber.phone_number_with_country_code
        fill_in "amount-field", with: 25
        click_button "Make my contribution"
      end

      using_wait_time(10) do
        expect(page).to have_content(I18n.t("charge.alerts.success", amount: "$25.00"))
      end
    end

    it "fails when trying to donate less than $5" do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
      visit "/"
      expect(page).to_not have_content("Log In") # checking user is logged in
      expect(page).to have_content("Pay what you can")

      click_link "one-time-donation"

      expect(page).to have_content(I18n.t("charge.new.title"))

      within "#payment-form" do
        fill_stripe_elements(card: "4242424242424242")
        fill_in "amount-field", with: 4
        click_button "Make my contribution"
        message = page.find("#amount-field").native.attribute("validationMessage")

        expect(message).to eq("Value must be greater than or equal to 5.")
      end
    end

    it "notifies when the transaction was declined" do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)
      visit "/"
      expect(page).to_not have_content("Log In") # checking user is logged in
      expect(page).to have_content("Pay what you can")

      click_link "one-time-donation"

      expect(page).to have_content(I18n.t("charge.new.title"))

      within ".one-time-donation" do
        fill_stripe_elements(card: "4000000000000002")
        fill_in "name-field", with: Faker::Name.name
        fill_in "email-field", with: Faker::Internet.email
        fill_in "phone-number-field", with: Faker::PhoneNumber.phone_number_with_country_code
        fill_in "amount-field", with: 25
        click_button "Make my contribution"
      end

      using_wait_time(10) do
        expect(page).to have_content("Your card was declined")
      end
    end

    it "donates to a specific fund from the list" do
      other_fund = FactoryBot.create(:fund, name: "Other Fund")
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(user)

      visit "/donate"
      expect(page).to have_content(I18n.t("charge.new.title"))

      funds = Fund.all
      funds.each { |fund| expect(page).to have_content(fund.name) }

      within "#payment-form" do
        # click on label radio button
        find(:css, "label[for=fund-#{other_fund.slug}").click
        fill_stripe_elements(card: "4242424242424242")
        fill_in "name-field", with: Faker::Name.name
        fill_in "email-field", with: Faker::Internet.email
        fill_in "phone-number-field", with: Faker::PhoneNumber.phone_number_with_country_code
        fill_in "amount-field", with: 25
        click_button "Make my contribution"
      end

      using_wait_time(10) do
        expect(page).to have_content(I18n.t("charge.alerts.success", amount: "$25.00"))
        expect(Donation.last.fund).to eq(other_fund)
      end
    end
  end

  context "as anonymous", js: true do
    it "allows going through the flow and prompts for a user account creation" do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(nil)
      visit "/"
      expect(page).to have_content("Log In") # checking user is logged in
      expect(page).to have_content("Pay what you can")

      click_link "one-time-donation"

      expect(page).to have_content(I18n.t("charge.new.title"))

      within ".one-time-donation" do
        fill_in "name-field", with: Faker::Name.name
        fill_in "email-field", with: Faker::Internet.email
        fill_in "phone-number-field", with: Faker::PhoneNumber.phone_number_with_country_code
        fill_stripe_elements(card: "4242424242424242")
        fill_in "amount-field", with: 25
        click_button "Make my contribution"
      end

      using_wait_time(10) do
        expect(page).to have_content(I18n.t("charge.alerts.success", amount: "$25.00"))
      end
    end

    it "notifies when the transaction was declined", js: true do
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(nil)
      visit "/"
      expect(page).to have_content("Log In") # checking user is logged in
      expect(page).to have_content("Pay what you can")

      click_link "one-time-donation"

      expect(page).to have_content(I18n.t("charge.new.title"))

      within ".one-time-donation" do
        fill_in "name-field", with: Faker::Name.name
        fill_in "email-field", with: Faker::Internet.email
        fill_in "phone-number-field", with: Faker::PhoneNumber.phone_number_with_country_code
        fill_stripe_elements(card: "4000000000000002")
        fill_in "amount-field", with: 25
        click_button "Make my contribution"
      end

      using_wait_time(10) do
        expect(page).to have_content("Your card was declined")
      end
    end

    it "donates to a specific fund from the list" do
      other_fund = FactoryBot.create(:fund, name: "Other Fund")
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(nil)

      visit "/donate"
      expect(page).to have_content(I18n.t("charge.new.title"))

      funds = Fund.all
      funds.each { |fund| expect(page).to have_content(fund.name) }

      within "#payment-form" do
        # click on label radio button
        find(:css, "label[for=fund-#{other_fund.slug}").click
        fill_stripe_elements(card: "4242424242424242")
        fill_in "name-field", with: Faker::Name.name
        fill_in "email-field", with: Faker::Internet.email
        fill_in "phone-number-field", with: Faker::PhoneNumber.phone_number_with_country_code
        fill_in "amount-field", with: 25
        click_button "Make my contribution"
      end

      using_wait_time(10) do
        expect(page).to have_content(I18n.t("charge.alerts.success", amount: "$25.00"))
        expect(Donation.last.fund).to eq(other_fund)
      end
    end
  end
end
