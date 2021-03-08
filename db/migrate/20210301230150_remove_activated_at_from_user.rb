class RemoveActivatedAtFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :activated_at, :datetime
  end
end
