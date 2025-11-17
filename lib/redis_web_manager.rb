# frozen_string_literal: true

# require external dependencies
require 'active_support/time'
require 'pagy'
require 'redis'

# require internal dependencies
require_relative 'redis_web_manager/engine'
require_relative 'redis_web_manager/base'
require_relative 'redis_web_manager/action'
require_relative 'redis_web_manager/connection'
require_relative 'redis_web_manager/info'
require_relative 'redis_web_manager/data'


module RedisWebManager
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
    def check_attrs # rubocop:disable Metrics/MethodLength
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
