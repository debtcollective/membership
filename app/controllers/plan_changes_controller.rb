# frozen_string_literal: true

class PlanChangesController < ApplicationController
  before_action :set_current_user_plan, only: %i[index create]

  # GET /plan_change
  def index
    redirect_to root_path unless current_user&.active_subscription
  end

  # GET /plan_change/new
  def new
    @plan_change = UserPlanChange.new
  end

  # POST /plan_change/new
  def create
    @plan = UserPlanChange.new(user_id: current_user.id, old_plan_id: @current_plan.id, new_plan_id: plan_params[:plan_id])

    respond_to do |format|
      if @plan.save
        format.html { redirect_to users_path(current_user), notice: 'Plan was successfully updated.' }
      else
        format.html { render :new }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_current_user_plan
    @current_plan = current_user&.active_subscription
  end

  def plan_change_params
    params.require(:plan_change).permit(:plan_id)
  end
end
