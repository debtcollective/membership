# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/plans/index', type: :view do
  let(:plan_1) { FactoryBot.attributes_for(:plan) }
  let(:plan_2) { FactoryBot.attributes_for(:plan) }

  before(:each) do
    assign(:plans, [
             Plan.create!(plan_1),
             Plan.create!(plan_2)
           ])
  end

  it 'renders a list of admin/plans' do
    render
    assert_select 'tr>td', text: plan_1[:name].to_s
    assert_select 'tr>td', text: plan_2[:name].to_s

    assert_select 'tr>td', text: plan_1[:description].to_s
    assert_select 'tr>td', text: plan_2[:description].to_s

    assert_select 'tr>td', text: "$#{plan_1[:amount]}"
    assert_select 'tr>td', text: "$#{plan_2[:amount]}"
  end
end
