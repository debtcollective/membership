class RemovePlans < ActiveRecord::Migration[6.0]
  def change
    remove_column :subscriptions, :plan_id
    drop_table :plans
    drop_table :user_plan_changes
  end
end
