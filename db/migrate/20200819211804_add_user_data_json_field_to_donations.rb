class AddUserDataJsonFieldToDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :donations, :user_data, :jsonb
  end
end
