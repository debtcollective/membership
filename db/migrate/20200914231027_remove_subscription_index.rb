class RemoveSubscriptionIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :subscriptions, [:user_id, :plan_id, :active]
  end
end
