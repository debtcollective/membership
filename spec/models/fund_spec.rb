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
require "rails_helper"

RSpec.describe Fund, type: :model do
  let(:fund) { FactoryBot.create(:fund) }
  subject { fund }

  describe "attributes" do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
