# frozen_string_literal: true

require "rails_helper"

describe AlgoliaPlacesClient do
  describe "#query" do
    it "returns search using zip code" do
      # Response from the Algolia places API
      query_response = <<-END
      {"hits":[{"country":{"de":"Vereinigte Staaten von Amerika","ru":"Соединённые Штаты Америки","pt":"Estados Unidos da América","it":"Stati Uniti d'America","fr":"États-Unis d'Amérique","hu":"Amerikai Egyesült Államok","es":"Estados Unidos de América","zh":"美国","ar":"الولايات المتّحدة الأمريكيّة","default":"United States of America","ja":"アメリカ合衆国","pl":"Stany Zjednoczone Ameryki","ro":"Statele Unite ale Americii","nl":"Verenigde Staten van Amerika"},"is_country":false,"city":{"default":["Canton"]},"is_highway":false,"importance":17,"_tags":["place/island","country/us","address","source/osm","place"],"postcode":["13617"],"county":{"default":["Saint Lawrence County"],"ru":["округ Сент-Лоренс"]},"population":6076,"country_code":"us","is_city":false,"is_popular":false,"administrative":["New York"],"admin_level":15,"is_suburb":false,"locale_names":{"default":["Willow Island"]},"_geoloc":{"lat":44.5947,"lng":-75.1739},"objectID":"99718134_83903548","_highlightResult":{"country":{"de":{"value":"Vereinigte Staaten von Amerika","matchLevel":"none","matchedWords":[]},"ru":{"value":"Соединённые Штаты Америки","matchLevel":"none","matchedWords":[]},"pt":{"value":"Estados Unidos da América","matchLevel":"none","matchedWords":[]},"it":{"value":"Stati Uniti d'America","matchLevel":"none","matchedWords":[]},"fr":{"value":"États-Unis d'Amérique","matchLevel":"none","matchedWords":[]},"hu":{"value":"Amerikai Egyesült Államok","matchLevel":"none","matchedWords":[]},"es":{"value":"Estados Unidos de América","matchLevel":"none","matchedWords":[]},"zh":{"value":"美国","matchLevel":"none","matchedWords":[]},"ar":{"value":"الولايات المتّحدة الأمريكيّة","matchLevel":"none","matchedWords":[]},"default":{"value":"United States of America","matchLevel":"none","matchedWords":[]},"ja":{"value":"アメリカ合衆国","matchLevel":"none","matchedWords":[]},"pl":{"value":"Stany Zjednoczone Ameryki","matchLevel":"none","matchedWords":[]},"ro":{"value":"Statele Unite ale Americii","matchLevel":"none","matchedWords":[]},"nl":{"value":"Verenigde Staten van Amerika","matchLevel":"none","matchedWords":[]}},"city":{"default":[{"value":"Canton","matchLevel":"none","matchedWords":[]}]},"postcode":[{"value":"<em>13617</em>","matchLevel":"full","fullyHighlighted":true,"matchedWords":["13617"]}],"county":{"default":[{"value":"Saint Lawrence County","matchLevel":"none","matchedWords":[]}],"ru":[{"value":"округ Сент-Лоренс","matchLevel":"none","matchedWords":[]}]},"administrative":[{"value":"New York","matchLevel":"none","matchedWords":[]}],"locale_names":{"default":[{"value":"Willow Island","matchLevel":"none","matchedWords":[]}]}}}],"nbHits":1,"processingTimeMS":28,"query":"13617","params":"query=13617&type=address&restrictSearchableAttributes=postcode&hitsPerPage=1","degradedQuery":false}
      END

      stub_request(:post, "https://places-dsn.algolia.net/1/places/query")
        .with(
          body: "{\"query\":\"13617\",\"type\":\"address\",\"restrictSearchableAttributes\":\"postcode\",\"hitsPerPage\":1}",
          headers: {
            "Accept" => "application/json",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/json",
            "Host" => "places-dsn.algolia.net",
            "User-Agent" => "Ruby",
            "X-Algolia-Api-Key" => "",
            "X-Algolia-Application-Id" => ""
          }
        ).to_return(status: 200, body: query_response, headers: {})

      json = AlgoliaPlacesClient.query("13617")

      expect(json[:country_code]).to eq("us")
      expect(json[:city]).to eq("Canton")
      expect(json[:state]).to eq("New York")
      expect(json[:county]).to eq("Saint Lawrence County")
      expect(json[:postcodes]).to include("13617")
    end

    it "returns search using zip code" do
      # Response from the Algolia places API
      query_response = <<-END
      {"hits":[{"country":{"de":"Vereinigte Staaten von Amerika","ru":"Соединённые Штаты Америки","pt":"Estados Unidos da América","it":"Stati Uniti d'America","fr":"États-Unis d'Amérique","hu":"Amerikai Egyesült Államok","es":"Estados Unidos de América","zh":"美国","ar":"الولايات المتّحدة الأمريكيّة","default":"United States of America","ja":"アメリカ合衆国","pl":"Stany Zjednoczone Ameryki","ro":"Statele Unite ale Americii","nl":"Verenigde Staten van Amerika"},"is_country":false,"city":{"ar":["سان فرانسيسكو"],"default":["San Francisco","SF"],"ru":["Сан-Франциско"],"pt":["São Francisco"],"ja":["サンフランシスコ"],"zh":["旧金山"]},"is_highway":true,"importance":26,"_tags":["highway","highway/residential","country/us","address","source/osm"],"postcode":["94118","94115"],"county":{"default":["San Francisco City and County","San Francisco","SF"],"ru":["Сан-Франциско"],"zh":["旧金山市县"]},"population":864816,"country_code":"us","is_city":false,"is_popular":false,"administrative":["California"],"admin_level":15,"is_suburb":false,"locale_names":{"default":["Anzavista Avenue"]},"_geoloc":{"lat":37.7795,"lng":-122.444},"objectID":"170678228_399595260","_highlightResult":{"country":{"de":{"value":"Vereinigte Staaten von Amerika","matchLevel":"none","matchedWords":[]},"ru":{"value":"Соединённые Штаты Америки","matchLevel":"none","matchedWords":[]},"pt":{"value":"Estados Unidos da América","matchLevel":"none","matchedWords":[]},"it":{"value":"Stati Uniti d'America","matchLevel":"none","matchedWords":[]},"fr":{"value":"États-Unis d'Amérique","matchLevel":"none","matchedWords":[]},"hu":{"value":"Amerikai Egyesült Államok","matchLevel":"none","matchedWords":[]},"es":{"value":"Estados Unidos de América","matchLevel":"none","matchedWords":[]},"zh":{"value":"美国","matchLevel":"none","matchedWords":[]},"ar":{"value":"الولايات المتّحدة الأمريكيّة","matchLevel":"none","matchedWords":[]},"default":{"value":"United States of America","matchLevel":"none","matchedWords":[]},"ja":{"value":"アメリカ合衆国","matchLevel":"none","matchedWords":[]},"pl":{"value":"Stany Zjednoczone Ameryki","matchLevel":"none","matchedWords":[]},"ro":{"value":"Statele Unite ale Americii","matchLevel":"none","matchedWords":[]},"nl":{"value":"Verenigde Staten van Amerika","matchLevel":"none","matchedWords":[]}},"city":{"ar":[{"value":"سان فرانسيسكو","matchLevel":"none","matchedWords":[]}],"default":[{"value":"San Francisco","matchLevel":"none","matchedWords":[]},{"value":"SF","matchLevel":"none","matchedWords":[]}],"ru":[{"value":"Сан-Франциско","matchLevel":"none","matchedWords":[]}],"pt":[{"value":"São Francisco","matchLevel":"none","matchedWords":[]}],"ja":[{"value":"サンフランシスコ","matchLevel":"none","matchedWords":[]}],"zh":[{"value":"旧金山","matchLevel":"none","matchedWords":[]}]},"postcode":[{"value":"94118","matchLevel":"none","matchedWords":[]},{"value":"<em>94115</em>","matchLevel":"full","fullyHighlighted":true,"matchedWords":["94115"]}],"county":{"default":[{"value":"San Francisco City and County","matchLevel":"none","matchedWords":[]},{"value":"San Francisco","matchLevel":"none","matchedWords":[]},{"value":"SF","matchLevel":"none","matchedWords":[]}],"ru":[{"value":"Сан-Франциско","matchLevel":"none","matchedWords":[]}],"zh":[{"value":"旧金山市县","matchLevel":"none","matchedWords":[]}]},"administrative":[{"value":"California","matchLevel":"none","matchedWords":[]}],"locale_names":{"default":[{"value":"Anzavista Avenue","matchLevel":"none","matchedWords":[]}]}}}],"nbHits":1,"processingTimeMS":27,"query":"94115","params":"query=94115&type=address&restrictSearchableAttributes=postcode&hitsPerPage=1","degradedQuery":false}
      END

      stub_request(:post, "https://places-dsn.algolia.net/1/places/query")
        .with(
          body: "{\"query\":\"94115\",\"type\":\"address\",\"restrictSearchableAttributes\":\"postcode\",\"hitsPerPage\":1}",
          headers: {
            "Accept" => "application/json",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/json",
            "Host" => "places-dsn.algolia.net",
            "User-Agent" => "Ruby",
            "X-Algolia-Api-Key" => "",
            "X-Algolia-Application-Id" => ""
          }
        ).to_return(status: 200, body: query_response, headers: {})

      json = AlgoliaPlacesClient.query("94115")

      expect(json[:country_code]).to eq("us")
      expect(json[:city]).to eq("San Francisco")
      expect(json[:state]).to eq("California")
      expect(json[:county]).to eq("San Francisco City and County")
      expect(json[:postcodes]).to include("94115")
    end

    it "returns search using zip code" do
      # Response from the Algolia places API
      query_response = <<-END
      {"hits":[{"country":{"de":"Mexiko","ru":"Мексика","en":"Mexico","it":"Messico","fr":"Mexique","hu":"Mexikó","zh":"墨西哥","ar":"المكسيك","default":"México","ja":"メキシコ","pl":"Meksyk","ro":"Mexic","nl":"Mexico"},"is_country":false,"city":{"de":["Mexiko-Stadt"],"ru":["Мехико"],"pt":["Cidade do México"],"en":["Mexico City"],"it":["Città del Messico"],"fr":["Mexico"],"hu":["Mexikóváros"],"zh":["墨西哥城"],"ar":["مدينة مكسيكو"],"default":["Ciudad de México","DF","CDMX"],"ja":["メキシコシティ"],"pl":["Meksyk"],"nl":["Mexico-Stad"]},"is_highway":true,"importance":26,"_tags":["highway","highway/residential","country/mx","address","source/osm"],"postcode":["07509","06140","09800","06170"],"county":{"default":["Gustavo A. Madero","Cuauhtémoc","Iztapalapa"]},"population":8555500,"country_code":"mx","is_city":false,"is_popular":false,"administrative":["Ciudad de México"],"admin_level":15,"is_suburb":false,"locale_names":{"default":["Calle Tula"]},"_geoloc":{"lat":19.4738,"lng":-99.0632},"objectID":"170086107_395207047","_highlightResult":{"country":{"de":{"value":"Mexiko","matchLevel":"none","matchedWords":[]},"ru":{"value":"Мексика","matchLevel":"none","matchedWords":[]},"en":{"value":"Mexico","matchLevel":"none","matchedWords":[]},"it":{"value":"Messico","matchLevel":"none","matchedWords":[]},"fr":{"value":"Mexique","matchLevel":"none","matchedWords":[]},"hu":{"value":"Mexikó","matchLevel":"none","matchedWords":[]},"zh":{"value":"墨西哥","matchLevel":"none","matchedWords":[]},"ar":{"value":"المكسيك","matchLevel":"none","matchedWords":[]},"default":{"value":"México","matchLevel":"none","matchedWords":[]},"ja":{"value":"メキシコ","matchLevel":"none","matchedWords":[]},"pl":{"value":"Meksyk","matchLevel":"none","matchedWords":[]},"ro":{"value":"Mexic","matchLevel":"none","matchedWords":[]},"nl":{"value":"Mexico","matchLevel":"none","matchedWords":[]}},"city":{"de":[{"value":"Mexiko-Stadt","matchLevel":"none","matchedWords":[]}],"ru":[{"value":"Мехико","matchLevel":"none","matchedWords":[]}],"pt":[{"value":"Cidade do México","matchLevel":"none","matchedWords":[]}],"en":[{"value":"Mexico City","matchLevel":"none","matchedWords":[]}],"it":[{"value":"Città del Messico","matchLevel":"none","matchedWords":[]}],"fr":[{"value":"Mexico","matchLevel":"none","matchedWords":[]}],"hu":[{"value":"Mexikóváros","matchLevel":"none","matchedWords":[]}],"zh":[{"value":"墨西哥城","matchLevel":"none","matchedWords":[]}],"ar":[{"value":"مدينة مكسيكو","matchLevel":"none","matchedWords":[]}],"default":[{"value":"Ciudad de México","matchLevel":"none","matchedWords":[]},{"value":"DF","matchLevel":"none","matchedWords":[]},{"value":"CDMX","matchLevel":"none","matchedWords":[]}],"ja":[{"value":"メキシコシティ","matchLevel":"none","matchedWords":[]}],"pl":[{"value":"Meksyk","matchLevel":"none","matchedWords":[]}],"nl":[{"value":"Mexico-Stad","matchLevel":"none","matchedWords":[]}]},"postcode":[{"value":"07509","matchLevel":"none","matchedWords":[]},{"value":"<em>06140</em>","matchLevel":"full","fullyHighlighted":true,"matchedWords":["06140"]},{"value":"09800","matchLevel":"none","matchedWords":[]},{"value":"06170","matchLevel":"none","matchedWords":[]}],"county":{"default":[{"value":"Gustavo A. Madero","matchLevel":"none","matchedWords":[]},{"value":"Cuauhtémoc","matchLevel":"none","matchedWords":[]},{"value":"Iztapalapa","matchLevel":"none","matchedWords":[]}]},"administrative":[{"value":"Ciudad de México","matchLevel":"none","matchedWords":[]}],"locale_names":{"default":[{"value":"Calle Tula","matchLevel":"none","matchedWords":[]}]}}}],"nbHits":1,"processingTimeMS":25,"query":"06140","params":"query=06140&type=address&restrictSearchableAttributes=postcode&hitsPerPage=1","degradedQuery":false}
      END

      stub_request(:post, "https://places-dsn.algolia.net/1/places/query").
        with(
          body: "{\"query\":\"06140\",\"type\":\"address\",\"restrictSearchableAttributes\":\"postcode\",\"hitsPerPage\":1}",
          headers: {
            "Accept" => "application/json",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/json",
            "Host" => "places-dsn.algolia.net",
            "User-Agent" => "Ruby",
            "X-Algolia-Api-Key" => "",
            "X-Algolia-Application-Id" => ""
          }
        ).to_return(status: 200, body: query_response, headers: {})

      json = AlgoliaPlacesClient.query("06140")

      expect(json[:country_code]).to eq("mx")
      expect(json[:city]).to eq("Ciudad de México")
      expect(json[:state]).to eq("Ciudad de México")
      expect(json[:postcodes]).to include("06140")
    end
  end

  around do |example|
    ClimateControl.modify(ALGOLIA_APP_ID: "", ALGOLIA_API_KEY: "") do
      example.run
    end
  end
end
