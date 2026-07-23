# frozen_string_literal: true

require 'spec_helper'
require 'connection_pool'

RSpec.describe RedisWebManager::ApplicationHelper, type: :helper do
  describe 'helper' do
    it 'fetches a connection attribute from a plain Redis' do
      expect(helper.fetch_attribute(Redis.new, :host)).to eq('localhost')
    end

    it 'fetches a connection attribute from a ConnectionPool' do
      pool = ConnectionPool.new(size: 1) { Redis.new }
      expect(helper.fetch_attribute(pool, :host)).to eq('localhost')
    end

    it 'returns status tag (true)' do
      expect(helper.status(true)).to include('ON')
    end

    it 'returns status tag (false)' do
      expect(helper.status(false)).to include('OFF')
    end

    it 'returns url tag' do
      expect(helper.url('test.com')).to include('kbd')
    end

    it 'returns a no expiration' do
      expect(helper.expiry(-1)).to eql('No expiration date')
    end

    it 'returns a expiration' do
      expect(helper.expiry(86_400)).to eql('1 day')
    end
  end
end
