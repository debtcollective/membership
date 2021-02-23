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

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      concat(
        content_tag(:div, message, class: "alert alert-#{msg_type}", role: "alert") {
          concat message
          concat content_tag(:button, content_tag(:span, "×", data: {'aria-hidden': "true"}),
            class: "close", data: {dismiss: "alert"})
        }
      )
    end

    nil
  end

  def discourse_url(path="/")
    "#{ENV["DISCOURSE_URL"]}#{path}"
  end
end
