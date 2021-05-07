class AddMetadataToSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :metadata, :jsonb, default: {}, null: false
  end
end
