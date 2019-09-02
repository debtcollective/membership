# frozen_string_literal: true

class CreateSubscriptionDonations < ActiveRecord::Migration[6.0]
  def change
    create_table :subscription_donations, id: :uuid do |t|
      t.belongs_to :subscription, type: :uuid, index: true
      t.belongs_to :donation, type: :uuid, index: true

      t.timestamps
    end

    add_index :subscription_donations, %i[subscription_id donation_id], unique: true
  end
end
