# frozen_string_literal: true

class Admin::DashboardController < AdminController
  before_action -> { current_page_title('Dashboard') }

  def index
    @active_subscriptions_count = Subscription.where(active: true).count
    subscriptions = Donation.where(status: 'finished', donation_type: Donation::DONATION_TYPES[:subscription])
    @amount_from_subscriptions = subscriptions.sum(&:amount).to_f

    one_off_donations = Donation.where(status: 'finished', donation_type: Donation::DONATION_TYPES[:one_off])
    @donations_count = one_off_donations.count
    @amount_from_donations = one_off_donations.sum(&:amount).to_f
  end
end
