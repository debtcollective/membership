class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :user_role
      t.string :discourse_id

      t.timestamps
    end
  end
end
