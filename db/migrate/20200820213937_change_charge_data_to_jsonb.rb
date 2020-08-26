class ChangeChargeDataToJsonb < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up { change_column :donations, :charge_data, :jsonb, using: "CAST(charge_data AS JSONB)", default: {}, null: false }
      dir.down { change_column :donations, :charge_data, :json, using: "CAST(charge_data AS JSON)", default: {}, null: false }
    end
  end
end
