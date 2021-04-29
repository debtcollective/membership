# frozen_string_literal: true

class MembershipsController < HubController
  def index
    @membership = Subscription.last
  end
end
