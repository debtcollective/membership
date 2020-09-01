class AddFundToDonations < ActiveRecord::Migration[6.0]
  def change
    add_reference :donations, :fund
  end
end
