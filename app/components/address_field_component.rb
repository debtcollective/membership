# frozen_string_literal: true

class AddressFieldComponent < ViewComponent::Base
  attr_reader :f

  def initialize(form:)
    @f = form
  end
end
