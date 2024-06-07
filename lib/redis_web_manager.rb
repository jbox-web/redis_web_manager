# frozen_string_literal: true

require 'active_support/time'
require 'redis'

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

module RedisWebManager
  require 'redis_web_manager/engine' if defined?(Rails)

  mattr_accessor :redises, default: { default: Redis.new }
  mattr_accessor :lifespan, default: 15.days
  mattr_accessor :authenticate, default: nil

  class << self
    def configure
      yield self if block_given?
      check_attrs
    end

    private

    # rubocop:disable Style/IfUnlessModifier
    def check_attrs
      unless redises.is_a?(::Hash)
        raise(ArgumentError, 'Invalid redises hash, use like that { test: Redis.new }')
      end

      redises.each do |k, v|
        unless v.is_a?(Redis)
          raise(ArgumentError, "Invalid Redis instance for #{k}, use like that Redis.new")
        end
      end

      unless lifespan.is_a?(::ActiveSupport::Duration)
        raise(ArgumentError, 'Invalid lifespan, use like that 15.days, 15.minutes etc')
      end

      valid = lifespan.to_i.positive?
      raise(ArgumentError, 'Invalid lifespan, value must be greater than 0') unless valid
    end
    # rubocop:enable Style/IfUnlessModifier

  end
end
