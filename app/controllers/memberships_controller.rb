# frozen_string_literal: true

class MembershipsController < HubController
  before_action :set_membership

  def index
  end

  def edit_amount
  end

  def update_amount
    amount_params = params.require(:membership).permit(:amount)
    @membership.assign_attributes(amount_params)

    respond_to do |format|
      if @membership.save
        format.html do
          flash[:success] = "Amount changed and it will be effective on your next billing"

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

  def edit_card
  end

  def update_card
    respond_to do |format|
      if @membership.update_credit_card!(update_card_params)
        format.json do
          flash[:success] = "Your credit card was updated, and it will be effective on your next billing"

          render json: {status: "succeeded", redirect_to: user_membership_path}, status: :ok
        end
      else
        format.json do
          flash[:error] = "There was an error updating your credit card, please try again or contact support"

          render json: {status: "failed", redirect_to: user_membership_path}, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_membership
    @membership = Subscription.last
  end

  def update_card_params
    params.require(:membership).permit(
      :address_city,
      :address_country_code,
      :address_line1,
      :address_state,
      :address_zip,
      :first_name,
      :last_name,
      :stripe_card_id,
      :stripe_card_last4,
      :stripe_token
    )
  end
end
