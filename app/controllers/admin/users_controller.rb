# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  # GET /admin/users
  # GET /admin/users.json
  def index
    @users = User.all
  end
end
