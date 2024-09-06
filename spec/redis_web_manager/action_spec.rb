# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RedisWebManager::Action do
  let(:action) do
    described_class.new(RedisWebManager.redises.keys[0])
  end

  let(:redis) do
    Redis.new
  end

  describe 'action' do
    it 'returns a OK (flushall)' do
      expect(action.flushall).to eq('OK')
    end

    it 'returns a OK (flushdb)' do
      expect(action.flushdb).to eq('OK')
    end

    it 'returns a 1 (del)' do
      redis.set('test', 'test')
      expect(action.del('test')).to eq(1)
    end

    it 'returns a OK (rename)' do
      redis.set('test', 'test')
      expect(action.rename('test', 'test2')).to eq('OK')
    end
  end
end
