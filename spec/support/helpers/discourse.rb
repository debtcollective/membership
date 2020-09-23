module Helpers
  module Discourse
    def stub_discourse_request(method, url, body = nil)
      params = {
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Api-Key" => ENV["DISCOURSE_API_KEY"],
          "Api-Username" => ENV["DISCOURSE_USERNAME"],
          "User-Agent" => "DiscourseAPI Ruby Gem 0.42.0"
        }
      }

      if body
        params[:body] = body if body
        params[:headers]["Content-Type"] = "application/x-www-form-urlencoded"
      end

      stub_request(method, "#{ENV["DISCOURSE_URL"]}/#{url}")
        .with(params)
    end
  end
end
