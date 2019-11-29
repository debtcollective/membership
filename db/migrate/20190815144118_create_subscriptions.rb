# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.belongs_to :user, index: true
      t.belongs_to :plan, index: true
      t.boolean :active

      t.timestamps
    end
  end
end
