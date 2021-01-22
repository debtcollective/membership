# frozen_string_literal: true

require "rails_helper"

RSpec.describe AddLocationDataToUserProfileJob do
  context "queue" do
    let(:user) { FactoryBot.create(:user) }
    subject(:job) { described_class.perform_later(user) }

    it "queues the job" do
      expect { job }
        .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it "is in default queue" do
      expect(AddLocationDataToUserProfileJob.new.queue_name).to eq("default")
    end
  end

  describe "#perform" do
    let(:user) { FactoryBot.create(:user, custom_fields: {address_zip: "13617", address_country_code: "us"}) }

    it "updates state and county with location data" do
      # Response from the Algolia places API
      query_response = <<-END
      {"hits":[{"country":{"de":"Vereinigte Staaten von Amerika","ru":"Соединённые Штаты Америки","pt":"Estados Unidos da América","it":"Stati Uniti d'America","fr":"États-Unis d'Amérique","hu":"Amerikai Egyesült Államok","es":"Estados Unidos de América","zh":"美国","ar":"الولايات المتّحدة الأمريكيّة","default":"United States of America","ja":"アメリカ合衆国","pl":"Stany Zjednoczone Ameryki","ro":"Statele Unite ale Americii","nl":"Verenigde Staten van Amerika"},"is_country":false,"city":{"default":["Canton"]},"is_highway":false,"importance":17,"_tags":["place/island","country/us","address","source/osm","place"],"postcode":["13617"],"county":{"default":["Saint Lawrence County"],"ru":["округ Сент-Лоренс"]},"population":6076,"country_code":"us","is_city":false,"is_popular":false,"administrative":["New York"],"admin_level":15,"is_suburb":false,"locale_names":{"default":["Willow Island"]},"_geoloc":{"lat":44.5947,"lng":-75.1739},"objectID":"99718134_83903548","_highlightResult":{"country":{"de":{"value":"Vereinigte Staaten von Amerika","matchLevel":"none","matchedWords":[]},"ru":{"value":"Соединённые Штаты Америки","matchLevel":"none","matchedWords":[]},"pt":{"value":"Estados Unidos da América","matchLevel":"none","matchedWords":[]},"it":{"value":"Stati Uniti d'America","matchLevel":"none","matchedWords":[]},"fr":{"value":"États-Unis d'Amérique","matchLevel":"none","matchedWords":[]},"hu":{"value":"Amerikai Egyesült Államok","matchLevel":"none","matchedWords":[]},"es":{"value":"Estados Unidos de América","matchLevel":"none","matchedWords":[]},"zh":{"value":"美国","matchLevel":"none","matchedWords":[]},"ar":{"value":"الولايات المتّحدة الأمريكيّة","matchLevel":"none","matchedWords":[]},"default":{"value":"United States of America","matchLevel":"none","matchedWords":[]},"ja":{"value":"アメリカ合衆国","matchLevel":"none","matchedWords":[]},"pl":{"value":"Stany Zjednoczone Ameryki","matchLevel":"none","matchedWords":[]},"ro":{"value":"Statele Unite ale Americii","matchLevel":"none","matchedWords":[]},"nl":{"value":"Verenigde Staten van Amerika","matchLevel":"none","matchedWords":[]}},"city":{"default":[{"value":"Canton","matchLevel":"none","matchedWords":[]}]},"postcode":[{"value":"<em>13617</em>","matchLevel":"full","fullyHighlighted":true,"matchedWords":["13617"]}],"county":{"default":[{"value":"Saint Lawrence County","matchLevel":"none","matchedWords":[]}],"ru":[{"value":"округ Сент-Лоренс","matchLevel":"none","matchedWords":[]}]},"administrative":[{"value":"New York","matchLevel":"none","matchedWords":[]}],"locale_names":{"default":[{"value":"Willow Island","matchLevel":"none","matchedWords":[]}]}}}],"nbHits":1,"processingTimeMS":28,"query":"13617","params":"query=13617&type=address&restrictSearchableAttributes=postcode&hitsPerPage=1","degradedQuery":false}
      END

      zip_code = user.custom_fields["address_zip"]
      country_code = user.custom_fields["address_country_code"]

      stub_request(:post, "https://places-dsn.algolia.net/1/places/query")
        .with(
          body: "{\"query\":\"#{zip_code}\",\"type\":\"address\",\"restrictSearchableAttributes\":\"postcode\",\"hitsPerPage\":1,\"countries\":[\"#{country_code}\"]}",
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

      perform_enqueued_jobs { AddLocationDataToUserProfileJob.perform_later(user_id: user.id) }

      user.reload

      expect(user.custom_fields["address_state"]).to eq("New York")
      expect(user.custom_fields["address_county"]).to eq("Saint Lawrence County")
      expect(user.custom_fields["address_geoloc"]).to eq({"lat" => 44.5947, "lng" => -75.1739})
    end

    it "reschedules job if Algolia returns degradedQuery" do
      zip_code = user.custom_fields["address_zip"]
      country_code = user.custom_fields["address_country_code"]

      # Response from the Algolia places API
      query_response = <<-END
      {"hits":[],"nbHits":0,"processingTimeMS":1,"query":"#{zip_code}","params":"query=40218&countries=%5B%22US%22%5D&type=address&restrictSearchableAttributes=postcode&hitsPerPage=1","degradedQuery":true}
      END

      stub_request(:post, "https://places-dsn.algolia.net/1/places/query")
        .with(
          body: "{\"query\":\"#{zip_code}\",\"type\":\"address\",\"restrictSearchableAttributes\":\"postcode\",\"hitsPerPage\":1,\"countries\":[\"#{country_code}\"]}",
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

      expect_any_instance_of(described_class).to receive(:retry_job)

      perform_enqueued_jobs { AddLocationDataToUserProfileJob.perform_now(user_id: user.id) }

      user.reload

      expect(user.custom_fields["address_state"]).to be_nil
      expect(user.custom_fields["address_county"]).to be_nil
      expect(user.custom_fields["address_geoloc"]).to be_nil
    end
  end

  around do |example|
    ClimateControl.modify(ALGOLIA_APP_ID: "", ALGOLIA_API_KEY: "") do
      example.run
    end
  end
end
