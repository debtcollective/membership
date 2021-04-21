# frozen_string_literal: true

class TextFieldComponent < ViewComponent::Base
  attr_reader :name, :f

  def initialize(name:, form:)
    @name = name
    @f = form
  end
end
