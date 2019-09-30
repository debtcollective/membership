# frozen_string_literal: true

class RenameChargeDateOnSubscription < ActiveRecord::Migration[6.0]
  def change
    rename_column :subscriptions, :last_charge, :last_charge_at
  end
end
