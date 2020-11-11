# frozen_string_literal: true

json.extract! plan, :id, :user_id, :active, :created_at, :updated_at
json.url plan_url(plan, format: :json)
