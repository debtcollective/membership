class AddRegistrationIpAddressToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :registration_ip_address, :inet
  end
end
