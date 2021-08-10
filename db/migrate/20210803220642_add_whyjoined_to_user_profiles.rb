class AddWhyjoinedToUserProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :user_profiles, :why_joined, :text
  end
end
