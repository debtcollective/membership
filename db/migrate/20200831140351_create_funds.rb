class CreateFunds < ActiveRecord::Migration[6.0]
  def change
    create_table :funds do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end

    add_index :funds, :slug, unique: true
  end
end
