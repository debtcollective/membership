# frozen_string_literal: true

class AddSubscriptionChange < ActiveRecord::Migration[6.0]
  def change
    create_table :user_plan_changes do |t|
      t.string :old_plan_id
      t.string :new_plan_id
      t.string :user_id

      t.timestamps
    end
  end
end
