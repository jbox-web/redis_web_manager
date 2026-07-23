# frozen_string_literal: true

module RedisWebManager
  class Engine < ::Rails::Engine
    isolate_namespace RedisWebManager

    # Loudly flag a production mount with no authentication: the tool exposes
    # destructive Redis operations (flushall/flushdb, key delete) to anyone who
    # can reach the mount path. The condition/warn lives in a class method so it
    # is unit-testable — the initializer body itself only runs once, at boot.
    def self.warn_missing_authentication(logger = Rails.logger)
      return unless defined?(Rails) && Rails.env.production? && RedisWebManager.authenticate.nil?

      logger&.warn(
        '[RedisWebManager] Mounted in production without `config.authenticate` — ' \
        'destructive Redis actions are exposed unauthenticated.'
      )
    end

    initializer 'redis_web_manager.authentication_warning' do |app|
      app.config.after_initialize { RedisWebManager::Engine.warn_missing_authentication }
    end

    initializer 'redis_web_manager.assets.precompile' do |app|
      # check if Rails api mode
      if app.config.respond_to?(:assets)
        if defined?(Sprockets) && Sprockets::VERSION >= '4'
          app.config.assets.precompile << 'redis_web_manager/application.js'
          app.config.assets.precompile << 'redis_web_manager/application.css'
        else
          # use a proc instead of a string
          app.config.assets.precompile << proc { |path| path == 'redis_web_manager/application.js' }
          app.config.assets.precompile << proc { |path| path == 'redis_web_manager/application.css' }
        end
      end
    end
  end
end
