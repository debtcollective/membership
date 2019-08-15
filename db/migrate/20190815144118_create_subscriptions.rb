# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.belongs_to :user
      t.belongs_to :plan
      t.boolean :active

      t.timestamps
    end
  end
end
