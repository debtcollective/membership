class AddSubscriptionAmountDefaultValue < ActiveRecord::Migration[6.0]
  def change
    change_column :subscriptions, :amount, :money, default: 0
  end
end
