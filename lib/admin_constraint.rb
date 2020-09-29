# frozen_string_literal: true

require_dependency "current_user"

class AdminConstraint
  def initialize(options = {})
    @require_master = options[:require_master]
  end

  def matches?(request)
    current_user = SessionProvider.new(request.cookies, request.session).current_user

    current_user&.admin?
  rescue
    false
  end
end
