# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RedisWebManager::DashboardController, type: :controller do
  routes { RedisWebManager::Engine.routes }

  let(:default) do
    RedisWebManager.redises.keys[0]
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { instance: default.to_s }
      expect(response).to be_successful
    end

    it 'redirects to the default instance when none is given' do
      get :index
      expect(response).to be_redirect
    end
  end
end
