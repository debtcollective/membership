# frozen_string_literal: true

class PhoneNumberFieldComponent < ViewComponent::Base
  attr_reader :name, :f

  def initialize(name:, form:)
    @name = name
    @f = form
  end

  def input_classes
    if errors
      "error"
    else
      ""
    end
  end

  def errors
    f.object.errors.to_hash.fetch(name, nil)
  end
end
