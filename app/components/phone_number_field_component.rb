# frozen_string_literal: true

class PhoneNumberFieldComponent < ViewComponent::Base
  attr_reader :name, :f

  def initialize(name:, form:)
    @name = name
    @f = form
  end
end
