class AlgoliaPlacesClient
  class << self
    QUERY_DEFAULT_OPTIONS = {type: "address", "restrictSearchableAttributes": "postcode", hitsPerPage: 1}

    # Returns JSON response or nil
    def query(query, options = QUERY_DEFAULT_OPTIONS)
      options = QUERY_DEFAULT_OPTIONS.merge(options)
      payload = {query: query}.merge(options)
      api_url = "https://places-dsn.algolia.net/1/places/query"

      response = Net::HTTP.post(
        URI(api_url),
        payload.to_json,
        headers
      )

      case response
      when Net::HTTPSuccess
        success_response(response)
      else
        Raven.capture_message("Error while making Algolia Places request", extra: {status: response.status, body: response.body}) if defined?(Raven)

        nil
      end
    end

    private

    def success_response(response)
      body = response.body
      json = JSON.parse(body)

      # Algolia limits some queries due server capacity
      # This probably is related to the upcoming deprecation of Places
      # https://www.algolia.com/blog/product/sunseting-our-places-feature/
      degraded_query = json["degradedQuery"]
      result = json["hits"].first

      if degraded_query && result.blank?
        return {degraded_query: true}.with_indifferent_access
      end

      # no results, return gracefully
      return if result.blank?

      # Algolia return postcode results as an array of string or as an array of objects
      # we handle the two cases here.
      #
      # Also, the value can return unsanitized HTML
      postcodes = result["postcode"]
      postcode = postcodes&.first

      if postcode && postcode.is_a?(Hash)
        postcode = ActionView::Base.full_sanitizer.sanitize(postcode["value"])
      end

      {
        city: result["city"]&.[]("default")&.first,
        country: result["country"]&.[]("default"),
        country_code: result["country_code"],
        county: result["county"]&.[]("default")&.first,
        objectID: result["objectID"],
        geoloc: result["_geoloc"],
        postcode: postcode,
        state: result["administrative"]&.first
      }.with_indifferent_access
    end

    def headers
      {
        accept: "application/json",
        "Content-Type": "application/json",
        "X-Algolia-Application-Id": ENV["ALGOLIA_APP_ID"],
        "X-Algolia-API-Key": ENV["ALGOLIA_API_KEY"]
      }
    end
  end
end
