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
  end
end
