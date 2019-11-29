# frozen_string_literal: true

class AddUserToDonation < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :donations, :user, index: true
  end
end
