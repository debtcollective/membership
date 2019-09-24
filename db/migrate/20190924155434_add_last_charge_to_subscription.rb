# frozen_string_literal: true

class AddLastChargeToSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :last_charge, :datetime
  end
end
