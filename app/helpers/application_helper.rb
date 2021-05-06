# frozen_string_literal: true

module ApplicationHelper
  def full_title(page_title = "")
    base_title = "Membership"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def flash_message_class(type)
    @flash_message_classes ||= {
      error: "red",
      info: "blue",
      success: "green",
      warning: "yellow"
    }

    @flash_message_classes[type.to_sym]
  end

  # current_path? returns false on POST request, we use this one instead.
  def current_path?(path)
    request.path == path
  end

  def discourse_url(path = "/")
    "#{ENV["DISCOURSE_URL"]}#{path}"
  end

  def country_options
    ISO3166::Country.codes.map do |code_or_name|
      if country = ISO3166::Country.new(code_or_name)
        code = country.alpha2
      elsif country = ISO3166::Country.find_by_name(code_or_name)
        code = country.first
        country = ISO3166::Country.new(code)
      end

      [country.name, code]
    end
  end
end
