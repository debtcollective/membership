# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/plans/show', type: :view do
  let(:plan) { FactoryBot.attributes_for(:plan) }
  before(:each) do
    @plan = assign(:plan, Plan.create!(plan))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/#{plan[:name]}/)
    expect(rendered).to match(/#{plan[:description]}/)
    expect(rendered).to match(/\$#{plan[:amount]}/)
  end
end
