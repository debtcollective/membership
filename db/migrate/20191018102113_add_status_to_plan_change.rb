# frozen_string_literal: true

class AddStatusToPlanChange < ActiveRecord::Migration[6.0]
  def change
    add_column :user_plan_changes, :status, :integer, default: 0
  end
end
