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
  DEFAULT_SLUG = "debt-collective"

  has_many :donations, dependent: :restrict_with_error

  validates :name, presence: true
  validates :slug, uniqueness: true

  after_commit :expire_funds_cache

  def self.default
    find_by!(slug: DEFAULT_SLUG)
  end

  private

  def expire_funds_cache
    Rails.cache.delete(FundsController::FUNDS_CACHE_KEY)
  end
end
