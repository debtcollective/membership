# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/users/index', type: :view do
  let(:email_1) { Faker::Internet.email }
  let(:email_2) { Faker::Internet.email }

  before(:each) do
    assign(:users, [
             User.create!(
               first_name: 'First Name',
               last_name: 'Last Name',
               email: email_1,
               user_role: User::USER_ROLES[:user],
               discourse_id: 'Discourse'
             ),
             User.create!(
               first_name: 'First Name',
               last_name: 'Last Name',
               email: email_2,
               user_role: User::USER_ROLES[:user],
               discourse_id: 'Discourse'
             )
           ])
  end

  it 'renders a list of users' do
    render
    assert_select 'tr>td', text: 'First Name'.to_s, count: 2
    assert_select 'tr>td', text: 'Last Name'.to_s, count: 2
    assert_select 'tr>td', text: email_1.to_s
    assert_select 'tr>td', text: email_2.to_s
    assert_select 'tr>td', text: User::USER_ROLES[:user].to_s, count: 2
    assert_select 'tr>td', text: 'Discourse'.to_s, count: 2
  end
end
