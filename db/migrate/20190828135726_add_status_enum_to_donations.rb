# frozen_string_literal: true

class AddStatusEnumToDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :donations, :status, :integer, default: 0
  end
end
