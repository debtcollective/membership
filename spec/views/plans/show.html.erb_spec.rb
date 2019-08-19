# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'plans/show', type: :view do
  let(:plan) { FactoryBot.attributes_for(:plan) }

  before(:each) do
    @plan = assign(:plan, Plan.create!(plan))
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{plan[:name]}/)
    expect(rendered).to match(/#{plan[:description]}/)
    expect(rendered).to match(/\$#{plan[:amount]}/)
  end
end
