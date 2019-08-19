# frozen_string_literal: true

class AddUniqueIndexToActiveSubscription < ActiveRecord::Migration[6.0]
  def change
    add_index :subscriptions, %i[user_id plan_id active], unique: true
  end
end
