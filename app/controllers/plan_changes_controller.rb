# frozen_string_literal: true

class PlanChangesController < ApplicationController
  before_action :set_current_user_plan, only: %i[index create]
  before_action :authenticate_user!, only: %i[create]

  # GET /users/:user_id/plan_changes
  def index
    redirect_to root_path unless current_user&.active_subscription

    @user = current_user
    @plans = Plan.all
  end

  # GET /users/:user_id/plan_changes/new
  # GET /users/:user_id/plan_changes/new.json
  def new
    @plan_change = UserPlanChange.new
  end

  # POST /users/:user_id/plan_changes
  # POST /users/:user_id/plan_changes.json
  def create
    @plan = UserPlanChange.new(user_id: current_user.id, old_plan_id: plan_change_params[:old_plan_id], new_plan_id: plan_change_params[:new_plan_id], status: 'pending')

    respond_to do |format|
      if @plan.save
        format.json { render json: @plan, status: :ok }
      else
        format.html { render :index }
      end
    end
  end

  private

  def set_current_user_plan
    @current_plan = current_user&.active_subscription&.plan
  end

  def plan_change_params
    params.require(:plan_change).permit(:old_plan_id, :new_plan_id)
  end
end
