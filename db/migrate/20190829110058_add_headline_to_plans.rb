# frozen_string_literal: true

class AddHeadlineToPlans < ActiveRecord::Migration[6.0]
  def change
    add_column :plans, :headline, :string
    change_column :plans, :description, :text
  end
end
