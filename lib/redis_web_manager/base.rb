# frozen_string_literal: true

module RedisWebManager
  class Base # rubocop:disable Metrics/ClassLength
    attr_accessor :instance

    def initialize(instance)
      @redises  = RedisWebManager.redises
      @instance = instance || redises.keys[0]
      @redis    = @redises[@instance.to_sym]
    end

    private

    attr_reader :redis, :redises

    def redis_connection
      if redis.is_a?(ConnectionPool)
        redis.with(&:connection)
      else
        redis.connection
      end
    end

    def redis_ping
      if connection_pool?
        redis.with { |con| con.ping == 'PONG' }
      else
        redis.ping == 'PONG'
      end
    end

    def redis_info
      if connection_pool?
        redis.with(&:info)
      else
        redis.info
      end
    end

    def redis_dbsize
      if connection_pool?
        redis.with(&:dbsize)
      else
        redis.dbsize
      end
    end

    def redis_configuration
      if connection_pool?
        redis.with { |con| con.config(:get, '*') }
      else
        redis.config(:get, '*')
      end
    end

    def redis_clients
      if connection_pool?
        redis.with { |con| con.client(:list) }
      else
        redis.client(:list)
      end
    end

    def redis_scan_each(query)
      if connection_pool?
        redis.with { |con| con.scan_each(**query).to_a }
      else
        redis.scan_each(**query).to_a
      end
    end

    def redis_type(key)
      if connection_pool?
        redis.with { |con| con.type(key) }
      else
        redis.type(key)
      end
    end

    def redis_ttl(key)
      if connection_pool?
        redis.with { |con| con.ttl(key) }
      else
        redis.ttl(key)
      end
    end

    def redis_memory_usage(key)
      if connection_pool?
        redis.with { |con| con.memory(:usage, key) }
      else
        redis.memory(:usage, key)
      end
    end

    def redis_get(key)
      if connection_pool?
        redis.with { |con| con.get(key) }
      else
        redis.get(key)
      end
    end

    def redis_llen(key)
      if connection_pool?
        redis.with { |con| con.llen(key) }
      else
        redis.llen(key)
      end
    end

    def redis_lrange(key, start, stop)
      if connection_pool?
        redis.with { |con| con.lrange(key, start, stop) }
      else
        redis.lrange(key, start, stop)
      end
    end

    def redis_smembers(key)
      if connection_pool?
        redis.with { |con| con.smembers(key) }
      else
        redis.smembers(key)
      end
    end

    def redis_zrange(key, start, stop, options = {})
      if connection_pool?
        redis.with { |con| con.zrange(key, start, stop, **options) }
      else
        redis.zrange(key, start, stop, **options)
      end
    end

    def redis_hgetall(key)
      if connection_pool?
        redis.with { |con| con.hgetall(key) }
      else
        redis.hgetall(key)
      end
    end

    def redis_flushall
      if connection_pool?
        redis.with(&:flushall)
      else
        redis.flushall
      end
    end

    def redis_flushdb
      if connection_pool?
        redis.with(&:flushdb)
      else
        redis.flushdb
      end
    end

    def redis_del(key)
      if connection_pool?
        redis.with { |con| con.del(key) }
      else
        redis.del(key)
      end
    end

    def redis_rename(old_name, new_name)
      if connection_pool?
        redis.with { |con| con.rename(old_name, new_name) }
      else
        redis.rename(old_name, new_name)
      end
    end

    def redis_setex(key, time, payload)
      if connection_pool?
        redis.with { |con| con.setex(key, time, payload) }
      else
        redis.setex(key, time, payload)
      end
    end

    def connection_pool?
      redis.is_a?(ConnectionPool)
    end
  end
end
