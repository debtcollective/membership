class TestPagesController < ApplicationController
  def widget_donation
    @title = "Donation widget"
  end

  def widget_subscription
    @title = "Membership widget"
  end
end
