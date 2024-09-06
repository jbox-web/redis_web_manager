# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RedisWebManager::Connection do
  let(:connection) do
    described_class.new(RedisWebManager.redises.keys[0])
  end

  describe 'connection' do
    it 'returns a host' do
      expect(connection.host).to eq('localhost')
    end

    it 'returns a port' do
      expect(connection.port).to eq(6379)
    end

    it 'returns a db' do
      expect(connection.db).to eq(0)
    end

    it 'returns an id' do
      expect(connection.id).to eq('redis://localhost:6379')
    end

    it 'returns a location' do
      expect(connection.location).to eq('localhost:6379')
    end
  end
end
