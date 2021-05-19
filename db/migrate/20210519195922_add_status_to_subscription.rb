class AddStatusToSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :status, :string, null: false, default: "inactive"
  end
end
