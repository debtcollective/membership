class AddStatusToSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :status, :string, null: false, default: "active", index: true
  end
end
