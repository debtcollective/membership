# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/edit', type: :view do
  before(:each) do
    @user = assign(:user, User.create!(
                            first_name: 'MyString',
                            last_name: 'MyString',
                            email: Faker::Internet.email,
                            user_role: User::USER_ROLES[:admin],
                            discourse_id: 'MyString'
                          ))
  end

  it 'renders the edit user form' do
    render

    assert_select 'form[action=?][method=?]', user_path(@user), 'post' do
      assert_select 'input[name=?]', 'user[first_name]'
      assert_select 'input[name=?]', 'user[last_name]'
      assert_select 'input[name=?]', 'user[email]'
      assert_select 'input[name=?]', 'user[user_role]'
      assert_select 'input[name=?]', 'user[discourse_id]'
    end
  end
end
