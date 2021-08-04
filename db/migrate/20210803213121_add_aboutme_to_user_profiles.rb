class AddAboutmeToUserProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :user_profiles, :about_me, :text
  end
end
