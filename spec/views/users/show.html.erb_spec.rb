# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user_email) { Faker::Internet.email }

  before(:each) do
    @user = assign(:user, FactoryBot.create(:user, name: 'Usuario'))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Usuario/)
  end
end
