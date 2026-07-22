# frozen_string_literal: true

module RedisWebManager
  class Data < Base
    BASE = 'RedisWebManager'

    def initialize(instance)
      super
      @data     = redis_scan_each(match: "#{BASE}_#{instance}_*")
      @lifespan = RedisWebManager.lifespan
      @stats    = redis_info.symbolize_keys
    end

    def keys
      data.filter_map do |key|
        raw = redis_get(key)
        next if raw.nil? # key expired/evicted between SCAN and GET

        JSON.parse(raw, symbolize_names: true)
      rescue JSON::ParserError
        next # skip a corrupt snapshot instead of failing the whole dashboard
      end
    end

    def perform
      now = Time.now
      # nsec keeps the key unique when several snapshots land in the same second
      redis_setex("#{BASE}_#{instance}_#{now.to_i}_#{now.nsec}", lifespan.to_i, serialize.to_json)
    end

    def flush
      data.map { |key| redis_del(key) }
    end

    private

    attr_reader :data, :lifespan, :stats

    def serialize
      {
        date: Time.now,
        memory: memory,
        client: client,
        cpu: cpu
      }
    end

    def memory
      {
        used_memory: stats[:used_memory],
        used_memory_rss: stats[:used_memory_rss],
        used_memory_peak: stats[:used_memory_peak],
        used_memory_overhead: stats[:used_memory_overhead],
        used_memory_startup: stats[:used_memory_startup],
        used_memory_dataset: stats[:used_memory_dataset]
      }
    end

    def client
      {
        connected_clients: stats[:connected_clients],
        blocked_clients: stats[:blocked_clients]
      }
    end

    def cpu
      {
        used_cpu_sys: stats[:used_cpu_sys],
        used_cpu_user: stats[:used_cpu_user],
        used_cpu_sys_children: stats[:used_cpu_sys_children],
        used_cpu_user_children: stats[:used_cpu_user_children]
      }
    end
  end
end
