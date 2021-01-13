class CypressController < ApplicationController
  skip_before_action :verify_authenticity_token

  def force_login
    user = if params[:email].present?
      User.find_by!(email: params.require(:email))
    else
      User.first!
    end

    sign_in(user)

    head :ok
  end

  def sign_in(user)
    # here we mock the user authentication
    ApplicationController.class_eval do
      define_method(:current_user) { CurrentUser.new(user, {}, user.persisted?) }
    end
  end
end
