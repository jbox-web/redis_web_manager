# frozen_string_literal: true

module RedisWebManager
  class Info < Base

    attr_reader :dbsize, :configuration, :clients, :status, :stats

    def initialize(instance)
      super
      @dbsize        = redis_dbsize
      @configuration = redis_configuration
      @clients       = redis_clients
      @status        = redis_ping
      @stats         = redis_info
    end

    def search(query)
      query.blank? ? [] : redis_scan_each(match: "*#{query}*")
    end

    def type(key)
      redis_type(key)
    end

    def expiry(key)
      redis_ttl(key)
    end

    def memory_usage(key)
      redis_memory_usage(key)
    end

    def get(key)
      redis_get(key)
    end

    def llen(key)
      redis_llen(key)
    end

    def lrange(key, start, stop)
      redis_lrange(key, start, stop)
    end

    def smembers(key)
      redis_smembers(key)
    end

    def zrange(key, start, stop, options = {})
      redis_zrange(key, start, stop, options)
    end

    def hgetall(key)
      redis_hgetall(key)
    end
  end
end
