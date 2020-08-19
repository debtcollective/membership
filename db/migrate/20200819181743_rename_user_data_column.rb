class RenameUserDataColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :donations, :user_data, :charge_data
  end
end
