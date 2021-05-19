class SubscriptionStatus < ActiveRecord::Migration[6.1]
  def up
    Subscription.where(active: true).find_in_batches do |subscriptions|
      subscriptions.each do |subscription|
        subscription.status = :active
        subscription.save
      end
    end

    Subscription.where(active: false).find_in_batches do |subscriptions|
      subscriptions.each do |subscription|
        subscription.status = :paused
        subscription.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
