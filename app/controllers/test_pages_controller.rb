class TestPagesController < ApplicationController
  layout "test_page"

  def widget_donation
    @title = "Donation widget"
  end

  def widget_subscription
    @title = "Membership widget"
  end
end
