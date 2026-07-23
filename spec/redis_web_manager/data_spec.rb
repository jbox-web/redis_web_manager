# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RedisWebManager::Data do
  let(:data) do
    described_class.new(RedisWebManager.redises.keys[0])
  end

  describe 'data' do
    it 'returns a OK (perform)' do
      expect(data.perform).to eql('OK')
    end

    it 'returns a Array of keys' do
      expect(data.keys).to be_a(Array)
    end

    it 'returns a Array of keys deleted' do
      expect(data.flush).to be_a(Array)
    end

    it 'skips malformed snapshot values instead of raising' do
      Redis.new.set("RedisWebManager_#{RedisWebManager.redises.keys[0]}_bad", 'not-json')
      expect { data.keys }.not_to raise_error
      expect(data.keys).to be_a(Array)
    end

    it 'skips snapshot keys that vanish between SCAN and GET' do
      key = "RedisWebManager_#{RedisWebManager.redises.keys[0]}_gone"
      Redis.new.set(key, 'irrelevant')
      # `data` captures the key list at construction (SCAN); deleting the key now
      # makes the later GET return nil, exercising the expired/evicted branch.
      data
      Redis.new.del(key)
      expect(data.keys).to eq([])
    end
  end
end
