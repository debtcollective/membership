# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlansController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/plans').to route_to('plans#index')
    end

    it 'routes to #show' do
      expect(get: '/plans/1').to route_to('plans#show', id: '1')
    end
  end
end
