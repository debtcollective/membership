# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i[show edit update destroy]
  before_action -> { current_page_title('Account Management') }

  # GET /admin/users
  # GET /admin/users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/1/edit
  def edit; end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
