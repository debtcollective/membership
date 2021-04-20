# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_20_210401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "donations", force: :cascade do |t|
    t.money "amount", scale: 2
    t.string "card_id"
    t.string "customer_stripe_id"
    t.string "donation_type"
    t.string "customer_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "charge_data", default: {}, null: false
    t.integer "status"
    t.bigint "user_id"
    t.string "charge_id"
    t.string "charge_provider", default: "stripe"
    t.jsonb "user_data", default: {}
    t.bigint "fund_id"
    t.bigint "subscription_id"
    t.index ["charge_id"], name: "index_donations_on_charge_id", unique: true
    t.index ["fund_id"], name: "index_donations_on_fund_id"
    t.index ["subscription_id"], name: "index_donations_on_subscription_id"
    t.index ["user_id"], name: "index_donations_on_user_id"
  end

  create_table "funds", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_funds_on_slug", unique: true
  end

  create_table "subscription_donations", force: :cascade do |t|
    t.bigint "subscription_id"
    t.bigint "donation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["donation_id"], name: "index_subscription_donations_on_donation_id"
    t.index ["subscription_id", "donation_id"], name: "index_subscription_donations_on_subscription_id_and_donation_id", unique: true
    t.index ["subscription_id"], name: "index_subscription_donations_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "start_date"
    t.datetime "last_charge_at"
    t.money "amount", scale: 2, default: "0.0"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.date "birthday"
    t.string "address_line1"
    t.string "address_line2"
    t.string "address_city"
    t.string "address_state"
    t.string "address_county"
    t.string "address_zip"
    t.string "address_country"
    t.string "address_country_code"
    t.decimal "address_lat", precision: 8, scale: 6
    t.decimal "address_long", precision: 9, scale: 6
    t.string "phone_number"
    t.string "facebook"
    t.string "twitter"
    t.string "instagram"
    t.string "website"
    t.boolean "subscribed_to_newsletter"
    t.boolean "profile_completed", default: false
    t.jsonb "custom_fields"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "registration_email"
    t.index ["profile_completed"], name: "index_user_profiles_on_profile_completed"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "stripe_id"
    t.boolean "admin", default: false
    t.string "avatar_url"
    t.boolean "banned", default: false
    t.jsonb "custom_fields", default: {}
    t.bigint "external_id"
    t.string "name"
    t.string "username"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "email_token"
    t.inet "registration_ip_address"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
