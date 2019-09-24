# frozen_string_literal: true

class AddStartDateToSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :start_date, :datetime
  end
end
