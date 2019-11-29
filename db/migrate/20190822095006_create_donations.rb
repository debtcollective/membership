# frozen_string_literal: true

class CreateDonations < ActiveRecord::Migration[6.0]
  def change
    create_table :donations do |t|
      t.money :amount
      t.string :card_id
      t.string :customer_stripe_id
      t.string :donation_type
      t.string :customer_ip

      t.timestamps
    end
  end
end
