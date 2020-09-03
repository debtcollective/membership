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
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to have_many(:donations).dependent(:restrict_with_error) }
  end

  describe ".default" do
    it "returns default fund" do
      default_fund = FactoryBot.create(:fund, slug: Fund::DEFAULT_SLUG)

      expect(Fund.default).to eq(default_fund)
    end
  end
end
