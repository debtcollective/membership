# frozen_string_literal: true

class AddUserToDonation < ActiveRecord::Migration[6.0]
  def change
    add_column :donations, :user_id, :uuid, index: true
  end
end
