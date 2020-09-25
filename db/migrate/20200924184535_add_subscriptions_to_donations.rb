class AddSubscriptionsToDonations < ActiveRecord::Migration[6.0]
  def change
    add_reference :donations, :subscription, index: true
  end
end
