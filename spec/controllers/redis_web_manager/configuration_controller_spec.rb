# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RedisWebManager::ConfigurationController, type: :controller do
  routes { RedisWebManager::Engine.routes }

  let(:default) do
    RedisWebManager.redises.keys[0]
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { instance: default.to_s }
      expect(response).to be_successful
    end
  end

  describe '#redact' do
    it 'masks secret-bearing configuration values' do
      redacted = controller.send(:redact,
                                 'requirepass' => 'supersecret',
                                 'masterauth' => 'anothersecret',
                                 'maxmemory' => '104857600')
      expect(redacted['requirepass']).to eq('********')
      expect(redacted['masterauth']).to eq('********')
      expect(redacted['maxmemory']).to eq('104857600')
    end

    it 'leaves empty secret values untouched' do
      redacted = controller.send(:redact, 'requirepass' => '')
      expect(redacted['requirepass']).to eq('')
    end
  end
end
