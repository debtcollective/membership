# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def home
    @plans = Plan.all.order('amount asc')
  end
end
