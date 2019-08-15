# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/users').to route_to('admin/users#index')
    end
  end
end
