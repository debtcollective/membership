# frozen_string_literal: true

class CreateSubscriptionDonations < ActiveRecord::Migration[6.0]
  def change
    create_table :subscription_donations do |t|
      t.belongs_to :subscription, index: true
      t.belongs_to :donation, index: true

      t.timestamps
    end

    add_index :subscription_donations, %i[subscription_id donation_id], unique: true
  end
end
