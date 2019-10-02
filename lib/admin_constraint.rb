# frozen_string_literal: true

require_dependency 'current_user'

class AdminConstraint
  def initialize(options = {})
    @require_master = options[:require_master]
  end

  def matches?(request)
    provider = Fundraising.session_provider.new(request.env)

    provider.current_user&.admin? &&
      custom_admin_check(request)
  rescue Fundraising::InvalidAccess, Fundraising::ReadOnly
    false
  end
end
