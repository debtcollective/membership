class RemoveUserConfirmationEmail < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :active, :boolean, default: false
    remove_column :users, :confirmation_token, :string, index: true
  end
end
