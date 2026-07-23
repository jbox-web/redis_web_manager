# frozen_string_literal: true

require 'spec_helper'
require 'connection_pool'

# Exercise the whole service layer through a ConnectionPool-wrapped Redis. The
# rest of the suite runs against a plain Redis, so without this file the
# `connection_pool?` (pool) branch of every `redis_*` method in Base — plus the
# pool paths in Connection and Data — is never executed. Seeding is done with a
# bare Redis.new (same localhost server/db) and reads go through the pooled
# service objects, proving the pool path returns the same contracts.
RSpec.describe 'ConnectionPool support' do # rubocop:disable RSpec/DescribeClass
  let(:pool)     { ConnectionPool.new(size: 1) { Redis.new } }
  let(:instance) { :default }
  let(:redis)    { Redis.new }

  around do |example|
    original = RedisWebManager.redises
    RedisWebManager.redises = { default: pool }
    example.run
    RedisWebManager.redises = original
  end

  describe RedisWebManager::Info do
    subject(:info) { described_class.new(instance) }

    it 'reports ping status through the pool' do
      expect(info.status).to be(true)
    end

    it 'reads dbsize, configuration and clients through the pool' do
      expect(info.dbsize).to be_a(Integer)
      expect(info.configuration).to be_a(Hash)
      expect(info.clients).to be_a(Array)
      expect(info.stats).to be_a(Hash)
    end

    it 'reads type, ttl and memory usage through the pool' do
      redis.set('test', 'test', ex: 20.seconds)
      expect(info.type('test')).to eq('string')
      expect(info.expiry('test')).to eq(20)
      expect(info.memory_usage('test')).to be_a(Integer).and be_positive
    end

    it 'searches keys through the pool' do
      redis.set('testtesttest', 'testtesttest')
      expect(info.search('testtesttest')).to eq(['testtesttest'])
    end

    it 'reads string, list, set, zset and hash values through the pool' do
      redis.set('str', 'test')
      redis.lpush('lst', '1')
      redis.lpush('lst', '2')
      redis.sadd('st', 'member')
      redis.zadd('zst', 10, '1')
      redis.hset('hsh', 'name', 'value')

      expect(info.get('str')).to eq('test')
      expect(info.llen('lst')).to eq(2)
      expect(info.lrange('lst', 0, -1)).to eq(%w[2 1])
      expect(info.smembers('st')).to eq(%w[member])
      expect(info.zrange('zst', 0, -1)).to eq(%w[1])
      expect(info.hgetall('hsh')).to eq('name' => 'value')
    end
  end

  describe RedisWebManager::Connection do
    subject(:connection) { described_class.new(instance) }

    it 'reads connection metadata through the pool' do
      expect(connection.host).to eq('localhost')
      expect(connection.port).to eq(6379)
      expect(connection.db).to eq(0)
      expect(connection.id).to eq('redis://localhost:6379')
      expect(connection.location).to eq('localhost:6379')
    end
  end

  describe RedisWebManager::Action do
    subject(:action) { described_class.new(instance) }

    it 'deletes and renames keys through the pool' do
      redis.set('test', 'test')
      expect(action.del('test')).to eq(1)
      redis.set('test', 'test')
      expect(action.rename('test', 'test2')).to eq('OK')
    end

    it 'flushes the db and all through the pool' do
      expect(action.flushdb).to eq('OK')
      expect(action.flushall).to eq('OK')
    end
  end

  describe RedisWebManager::Data do
    subject(:data) { described_class.new(instance) }

    it 'writes, reads and flushes dashboard snapshots through the pool' do
      expect(data.perform).to eql('OK')
      expect(data.keys).to be_a(Array)
      expect(data.flush).to be_a(Array)
    end
  end
end
