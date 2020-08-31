class AddFundToDonations < ActiveRecord::Migration[6.0]
  def change
    add_reference :donations, :fund, foreign_key: true
  end
end
