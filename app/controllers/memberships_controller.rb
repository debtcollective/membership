# frozen_string_literal: true

class MembershipsController < HubController
  before_action :set_membership

  def index
  end

  def edit_amount
  end

  def update_amount
    membership_params = params.require(:subscription).permit(:amount)
    @membership.assign_attributes(membership_params)

    respond_to do |format|
      if @membership.save
        format.html do
          flash[:success] = "Amount changed and it will be effective on your next charge"

          redirect_to action: :index
        end
      else
        format.html do
          flash[:error] = "There were errors updating your membership"

          render :edit_amount
        end
      end
    end
  end

  def update_credit_card
  end

  private

  def set_membership
    @membership = Subscription.last
  end
end
