class MigrateUserProfile < ActiveRecord::Migration[6.1]
  def up
    User.find_each do |user|
      user_profile = user.find_or_create_user_profile
      custom_fields = user.custom_fields

      # update user profile with custom_fields

      user_profile.save(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
