# frozen_string_literal: true

class UsersController < ApplicationController
  def current
    respond_to do |format|
      if @user
        format.json { render json: current_user.as_json, status: :ok }
      else
        format.json { render json: nil, status: :not_found }
      end
    end
  end
end
