class CreateUserProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :user_profiles do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.date :birthday
      t.string :address_line1
      t.string :address_line2
      t.string :address_city
      t.string :address_state
      t.string :address_county
      t.string :address_zip
      t.string :address_country
      t.string :address_country_code
      t.decimal :address_lat, precision: 8, scale: 6
      t.decimal :address_long, precision: 9, scale: 6
      t.string :phone_number
      t.string :facebook
      t.string :twitter
      t.string :instagram
      t.string :website

      t.boolean :subscribed_to_newsletter
      t.boolean :profile_completed, default: false, index: true
      t.jsonb :custom_fields

      t.belongs_to :user

      t.timestamps
    end
  end
end
