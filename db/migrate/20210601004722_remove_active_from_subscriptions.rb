class RemoveActiveFromSubscriptions < ActiveRecord::Migration[6.1]
  def change
    remove_column :subscriptions, :active
  end
end
