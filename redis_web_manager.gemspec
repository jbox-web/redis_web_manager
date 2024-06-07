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

  s.required_ruby_version = '>= 3.0.0'

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency 'pagy', '>= 5.0', '< 6'
  s.add_runtime_dependency 'rails', '>= 5.2', '< 8'
  s.add_runtime_dependency 'redis', '>= 4.1.0', '< 6'
  s.add_runtime_dependency 'sprockets-rails', '~> 3.4.2'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'debug'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rake'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'ruby-lsp'
  s.add_development_dependency 'simplecov'

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
    s.add_development_dependency "base64"
    s.add_development_dependency "bigdecimal"
    s.add_development_dependency "mutex_m"
    s.add_development_dependency "drb"
  end
end
