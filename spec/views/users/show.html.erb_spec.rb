# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user_email) { Faker::Internet.email }

  before(:each) do
    @user = assign(:user, User.create!(
                            first_name: 'First Name',
                            last_name: 'Last Name',
                            email: user_email,
                            user_role: User::USER_ROLES[:user],
                            discourse_id: 'Discourse'
                          ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/#{user_email}/)
    expect(rendered).to match(/#{User::USER_ROLES[:user]}/)
    expect(rendered).to match(/Discourse/)
  end
end
