class ChangeUserCustomFieldsDefault < ActiveRecord::Migration[6.0]
  def up
    change_column_default :users, :custom_fields, {}
  end

  def down
    change_column_default :users, :custom_fields, nil
  end
end
