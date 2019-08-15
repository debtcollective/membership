# frozen_string_literal: true

class CreatePlans < ActiveRecord::Migration[6.0]
  def change
    create_table :plans, id: :uuid do |t|
      t.money :amount
      t.string :description
      t.string :name

      t.timestamps
    end
  end
end
