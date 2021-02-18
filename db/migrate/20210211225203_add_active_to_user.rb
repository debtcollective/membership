class AddActiveToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :active, :boolean, default: false
    add_column :users, :activated_at, :datetime
  end
end
