# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def home
    @current_user = current_user
    @plans = Plan.all.order('amount asc')
  end
end
