class HubController < ApplicationController
  before_action :authenticate_user!
end
