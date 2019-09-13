# frozen_string_literal: true

require 'rails_helper'

describe 'Welcome page', type: :feature do
  it 'loads the home page' do
    visit '/'
    expect(page).to have_content('Every membership brings us closer to our goals.')
  end
end
