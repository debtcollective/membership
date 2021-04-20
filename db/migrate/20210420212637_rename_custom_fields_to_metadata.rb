class RenameCustomFieldsToMetadata < ActiveRecord::Migration[6.1]
  def up
    rename_column :user_profiles, :custom_fields, :metadata
    change_column_default :user_profiles, :metadata, {}
  end

  def down
    rename_column :user_profiles, :metadata, :custom_fields
    change_column_default :user_profiles, :custom_fields, nil
  end
end
