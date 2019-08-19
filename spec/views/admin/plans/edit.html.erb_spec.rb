# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/plans/edit', type: :view do
  before(:each) do
    @plan = assign(:plan, Plan.create!(FactoryBot.attributes_for(:plan)))
  end

  it 'renders the edit plan form' do
    render

    assert_select 'form[action=?][method=?]', admin_plan_path(@plan), 'post' do
      assert_select 'input[name=?]', 'plan[name]'
      assert_select 'input[name=?]', 'plan[description]'
      assert_select 'input[name=?]', 'plan[amount]'
    end
  end
end
