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
    priority_countries = ["US", "CA", "GB"]
    country_codes = ISO3166::Country.codes.sort
    sorted_country_codes = priority_countries + (country_codes - priority_countries)

    sorted_country_codes.map { |code|
      country = ISO3166::Country.new(code)
      country_name = country.translations[I18n.locale.to_s]
      [country_name, code]
    }
  end
end
