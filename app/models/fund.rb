# == Schema Information
#
# Table name: funds
#
#  id         :bigint           not null, primary key
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_funds_on_slug  (slug) UNIQUE
#
class Fund < ApplicationRecord
  validates :name, presence: true
  validates :slug, uniqueness: true
end
