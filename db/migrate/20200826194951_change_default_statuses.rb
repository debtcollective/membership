class ChangeDefaultStatuses < ActiveRecord::Migration[6.0]
  def up
    change_column_default :donations, :status, "pending"
    change_column_default :user_plan_changes, :status, "pending"
  end

  def down
    change_column_default :donations, :status, 0
    change_column_default :user_plan_changes, :status, 0
  end
end
