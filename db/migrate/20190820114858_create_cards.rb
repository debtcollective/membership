# frozen_string_literal: true

class CreateCards < ActiveRecord::Migration[6.0]
  def change
    create_table :cards, id: :uuid do |t|
      t.belongs_to :user, type: :uuid, index: true
      t.string :brand
      t.integer :exp_month
      t.integer :exp_year
      t.string :last_digits

      t.timestamps
    end
  end
end
