# frozen_string_literal: true

class AddUserSsoFields < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string
    add_column :users, :admin, :boolean, default: false, index: true
    add_column :users, :banned, :boolean, default: false, index: true
    add_column :users, :external_id, :bigint, unique: true, index: true
    add_column :users, :custom_fields, :jsonb

    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :user_role
    remove_column :users, :discourse_id
  end
end
