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

          render :index
        end
      end
    end
  end

  def edit_card
  end

  def update_card
    card_updated = @membership.update_credit_card!(update_card_params)

    if !card_updated
      respond_to do |format|
        format.json do
          flash[:error] = I18n.t("memberships.update_card.error")

          render json: {status: "failed", redirect_to: user_membership_path}, status: :unprocessable_entity
        end
      end

      return
    end

    if !@membership.should_charge?
      respond_to do |format|
        format.json do
          flash[:success] = I18n.t("memberships.update_card.next_cycle")

          render json: {status: "succeeded", redirect_to: user_membership_path}, status: :ok
        end
      end

      return
    end

    respond_to do |format|
      if @membership.charge!
        format.json do
          flash[:success] = I18n.t("memberships.update_card.paid")

          render json: {status: "succeeded", redirect_to: user_membership_path}, status: :ok
        end
      else
        format.json do
          flash[:error] = I18n.t("memberships.update_card.error")

          render json: {status: "failed", redirect_to: user_membership_path}, status: :unprocessable_entity
        end
      end
    end
  end

  def edit_status
  end

  def pause
    respond_to do |format|
      if @membership.paused!
        format.html do
          flash[:success] = "Your membership is now paused"

          redirect_to action: :index
        end
      else
        format.html do
          flash[:error] = "There were errors updating your membership"

          render :edit_status
        end
      end
    end
  end

  def resume
    respond_to do |format|
      if @membership.active!
        format.html do
          flash[:success] = "Your membership is now active"

          redirect_to action: :index
        end
      else
        format.html do
          flash[:error] = "There were errors updating your membership"

          render :edit_status
        end
      end
    end
  end

  private

  def set_membership
    @membership = current_user.subscription
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
