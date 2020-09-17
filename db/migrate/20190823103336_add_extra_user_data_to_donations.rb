# frozen_string_literal: true

class AddExtraUserDataToDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :donations, :user_data, :json, null: false, default: {}
  end
end
