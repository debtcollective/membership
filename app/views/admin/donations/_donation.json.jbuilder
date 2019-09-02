# frozen_string_literal: true

json.extract! donation, :id, :amount, :created_at, :updated_at
json.url admin_donation_url(donation, format: :json)
