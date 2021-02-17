class AddIndexToUsersEmail < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :users, :email, unique: true, algorithm: :concurrently
  end
end


emails = {}

User.find_each do |user|
  emails[user.email.downcase] = emails[user.email.downcase].to_i + 1
end
