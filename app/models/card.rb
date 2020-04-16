# == Schema Information
#
# Table name: cards
#
#  id             :bigint           not null, primary key
#  brand          :string
#  exp_month      :integer
#  exp_year       :integer
#  last_digits    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  stripe_card_id :string
#  user_id        :bigint
#
# Indexes
#
#  index_cards_on_user_id  (user_id)
#
class Card < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
end
