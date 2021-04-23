# frozen_string_literal: true

class TextFieldComponent < ViewComponent::Base
  attr_reader :name, :f

  def initialize(name:, form:)
    @name = name
    @f = form
  end

  def input_classes
    classes = "block w-full sm:text-sm"
    normal_classes = "border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
    error_classes = "pr-10 text-red-900 placeholder-red-300 border-red-300 rounded-md focus:outline-none focus:ring-red-500 focus:border-red-500"

    if errors
      "#{classes} #{error_classes}"
    else
      "#{classes} #{normal_classes}"
    end
  end

  def errors
    f.object.errors.to_hash.fetch(name, nil)
  end
end
