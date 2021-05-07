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
    customer = current_user.find_stripe_customer

    Stripe::Customer.update(
      customer.id,
      {source: update_card_params[:stripe_token]}
    )

    @membership.metadata = {
      payment_method: {
        type: "card",
        last4: update_card_params[:stripe_card_last4],
        card_id: update_card_params[:stripe_card_id]
      }
    }
    @membership.save

    flash[:success] = "Your credit card was updated amd it will be used on your next billing"

    redirect_to action: :index
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
