# frozen_string_literal: true

module RedisWebManager
  class Action < Base
    def flushall
      redis_flushall
    end

    def flushdb
      redis_flushdb
    end

    def del(key)
      redis_del(key)
    end

    def rename(old_name, new_name)
      redis_rename(old_name, new_name)
    end
  end
end
