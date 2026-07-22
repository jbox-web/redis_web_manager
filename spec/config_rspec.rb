# frozen_string_literal: true

# Configure RSpec
RSpec.configure do |config|
  # config.order = :random
  # Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!

  # The suite hits a real Redis and is already destructive (see action_spec).
  # Start every example from a clean db so tests don't leak state into each
  # other (or across runs).
  config.before do
    Redis.new.flushdb
  end
end
