# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/index', type: :view do
  before(:each) do
    assign(:users, [
             User.create!(
               first_name: 'First Name',
               last_name: 'Last Name',
               email: 'Email',
               user_role: 'User Role',
               discourse_id: 'Discourse'
             ),
             User.create!(
               first_name: 'First Name',
               last_name: 'Last Name',
               email: 'Email',
               user_role: 'User Role',
               discourse_id: 'Discourse'
             )
           ])
  end

  it 'renders a list of users' do
    render
    assert_select 'tr>td', text: 'First Name'.to_s, count: 2
    assert_select 'tr>td', text: 'Last Name'.to_s, count: 2
    assert_select 'tr>td', text: 'Email'.to_s, count: 2
    assert_select 'tr>td', text: 'User Role'.to_s, count: 2
    assert_select 'tr>td', text: 'Discourse'.to_s, count: 2
  end
end
