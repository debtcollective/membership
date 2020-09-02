class Admin::FundsController < AdminController
  before_action :set_fund, only: %i[show edit update destroy]
  before_action -> { current_page_title("Funds") }

  def index
    @funds = Fund.all
  end

  def new
    @fund = Fund.new
  end

  def edit
  end

  def update
    respond_to do |format|
      if @fund.update(fund_params)
        format.html { redirect_to admin_funds_path, notice: "Fund was successfully updated." }
        format.json { render :show, status: :ok, location: @fund }
      else
        format.html { render :edit }
        format.json { render json: @fund.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @fund = Fund.new(fund_params)

    respond_to do |format|
      if @fund.save
        format.html { redirect_to admin_funds_path, notice: "Fund was successfully created." }
        format.json { render :show, status: :created, location: @fund }
      else
        format.html { render :new }
        format.json { render json: @fund.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @fund.destroy
        format.html { redirect_to admin_funds_path, notice: "Fund was successfully destroyed." }
        format.json { head :no_content }
      else
        format.html { redirect_to admin_funds_path, notice: @fund.errors[:base].join(", ") }
        format.json { render json: {error: @fund.errors[:base].join(", ")}, status: 400 }
      end
    end
  end

  private

  def set_fund
    @fund = Fund.find(params[:id])
  end

  def fund_params
    params.require(:fund).permit(:name, :slug)
  end
end
