# frozen_string_literal: true

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
require 'rails_helper'

RSpec.describe Card, type: :model do
  let!(:card) { FactoryBot.create(:card) }

  subject { card }

  describe 'attributes' do
    it { is_expected.to respond_to(:brand) }
    it { is_expected.to respond_to(:user_id) }
    it { is_expected.to respond_to(:exp_month) }
    it { is_expected.to respond_to(:exp_year) }
    it { is_expected.to respond_to(:last_digits) }
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
  end
end
