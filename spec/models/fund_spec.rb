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
