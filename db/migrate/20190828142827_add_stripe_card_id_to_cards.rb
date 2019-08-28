# frozen_string_literal: true

class AddStripeCardIdToCards < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :stripe_card_id, :string
  end
end
