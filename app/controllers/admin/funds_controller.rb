class Admin::FundsController < AdminController
  before_action :set_plan, only: %i[show edit update destroy]
  before_action -> { current_page_title("Funds") }

  def index
    @funds = Fund.all
  end
end
