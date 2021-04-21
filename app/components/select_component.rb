# frozen_string_literal: true

class SelectComponent < ViewComponent::Base
  attr_reader :name, :options, :f, :include_blank

  def initialize(name:, options:, form:, include_blank: false)
    @name = name
    @options = options
    @include_blank = include_blank
    @f = form
  end
end
