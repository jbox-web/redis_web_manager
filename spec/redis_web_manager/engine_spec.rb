# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RedisWebManager::Engine do
  describe '.warn_missing_authentication' do
    let(:logger) { instance_double(Logger, warn: nil) }

    # `authenticate` is a shared module-level accessor; keep it hermetic.
    around do |example|
      saved = RedisWebManager.authenticate
      example.run
      RedisWebManager.authenticate = saved
    end

    def stub_env(name)
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(name))
    end

    it 'warns when mounted in production without authentication' do
      stub_env('production')
      RedisWebManager.authenticate = nil
      described_class.warn_missing_authentication(logger)
      expect(logger).to have_received(:warn).with(/without `config.authenticate`/)
    end

    it 'does not warn outside production' do
      stub_env('test')
      RedisWebManager.authenticate = nil
      described_class.warn_missing_authentication(logger)
      expect(logger).not_to have_received(:warn)
    end

    it 'does not warn when authentication is configured' do
      stub_env('production')
      RedisWebManager.authenticate = -> { true }
      described_class.warn_missing_authentication(logger)
      expect(logger).not_to have_received(:warn)
    end

    it 'is a no-op when there is no logger' do
      stub_env('production')
      RedisWebManager.authenticate = nil
      expect { described_class.warn_missing_authentication(nil) }.not_to raise_error
    end
  end
end
