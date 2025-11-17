# frozen_string_literal: true

require_relative 'lib/redis_web_manager/version'

Gem::Specification.new do |s|
  s.name        = 'redis_web_manager'
  s.version     = RedisWebManager::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Boris BRESCIANI', 'Benjamin DARCET', 'Olivier DUMAS']
  s.email       = ['boris2bresciani@gmail.com', 'b.darcet@gmail.com', 'dumas.olivier@outlook.fr']
  s.homepage    = 'https://github.com/OpenGems/redis_web_manager'
  s.summary     = 'Manage your Redis instance (See keys, memory used, connected client, etc...)'
  s.description = 'Manage your Redis instance (See keys, memory used, connected client, configuration, information)'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.2.0'

  s.files = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*.rb',
    'config/**/*.rb',
    'app/**/*.rb',
    'app/**/*.erb',
    'app/**/*.js',
    'app/**/*.css'
  ]

  s.add_dependency 'pagy', '>= 43.0'
  s.add_dependency 'rails', '>= 7.2'
  s.add_dependency 'redis', '>= 4.1.0'
  s.add_dependency 'sprockets-rails', '>= 3.4.0'
end
