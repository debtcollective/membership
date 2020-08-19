class AddChargeInfoToDonation < ActiveRecord::Migration[6.0]
  def change
    add_column :donations, :charge_id, :string
    add_column :donations, :charge_provider, :string, default: "stripe"

    add_index :donations, :charge_id, unique: true
  end
end
