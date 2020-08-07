# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def home
    flash[:info] = 'te amo'
    @current_user = current_user
    @current_user_subscription = @current_user&.active_subscription
    @plans = Plan.all.order('amount asc')
  end

  def thank_you; end
end
