# frozen_string_literal: true

module ApplicationHelper
  # Returns the full title on a per-page basis.
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
end
