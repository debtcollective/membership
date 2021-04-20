class AddRegistrationEmailToUserProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :user_profiles, :registration_email, :string
  end
end
