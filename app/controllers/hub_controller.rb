class HubController < ApplicationController
  before_action :authenticate_user!
  before_action :allowed_to_view?

  def allowed_to_view?
    return true if current_user.email&.ends_with?("@debtcollective.org")

    if request.get?
      redirect_to_home_page
    else
      head :unauthorized
    end
  end
end
