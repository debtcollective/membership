# frozen_string_literal: true

class UsersController < ApplicationController
  layout "backoffice"
  before_action :authenticate_user!
  before_action :set_user

  # GET /users/1
  # GET /users/1.json
  def show
    current_page_title("Your dashboard")
  end

  # pages
  def subscription
    current_page_title("Subscription management")

    @is_subscription_changing = UserPlanChange.where(user_id: @user.id, status: "pending").first
    @subscription = @user.active_subscription
  end

  def donation_history
    current_page_title("Donation history")

    # pass donations with receipt_url attribute to react component
    @donations = JSON.parse(@user.donations.to_json(methods: :receipt_url))
  end

  private

  def current_page_title(page_title)
    @current_page_title ||= page_title
  end

  # TODO: Check why we can't use current_user helper method when passing props to react_component
  #       only instance variable seems to work
  def set_user
    @user = current_user
  end
end
