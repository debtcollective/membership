# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/plans/new', type: :view do
  before(:each) do
    assign(:plan, Plan.new)
  end

  it 'renders new plan form' do
    render

    assert_select 'form[action=?][method=?]', admin_plans_path, 'post' do
      assert_select 'input[name=?]', 'plan[name]'
      assert_select 'input[name=?]', 'plan[description]'
      assert_select 'input[name=?]', 'plan[amount]'
    end
  end
end
