# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StreaksController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let!(:subscription) { FactoryBot.create(:subscription, start_date: 3.months.ago, user_id: user.id) }

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { user_id: user.to_param }

      json_response = JSON.parse(response.body)

      expect(json_response).to match('current_streak' => '3 months')
    end
  end
end
