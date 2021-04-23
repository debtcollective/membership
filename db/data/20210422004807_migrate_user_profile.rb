class MigrateUserProfile < ActiveRecord::Migration[6.1]
  def up
    User.find_each do |user|
      user_profile = user.find_or_create_user_profile
      custom_fields = user.custom_fields
      address_geoloc = custom_fields["address_geoloc"] || {}

      user_profile.assign_attributes({
        address_city: custom_fields["address_city"],
        address_country: custom_fields["address_country"],
        address_country_code: custom_fields["address_country_code"],
        address_lat: address_geoloc["lat"],
        address_line1: custom_fields["address_line1"],
        address_long: address_geoloc["lng"],
        address_state: custom_fields["address_state"],
        address_zip: custom_fields["address_zip"],
        first_name: user.first_name,
        last_name: user.last_name,
        phone_number: custom_fields["phone_number"],
        registration_email: custom_fields["email"]
      })

      user_profile.metadata = {"address_county": custom_fields["address_county"]} if custom_fields["address_county"].present?
      user.registration_ip_address = custom_fields["customer_ip"]

      user.save
      user_profile.save(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
