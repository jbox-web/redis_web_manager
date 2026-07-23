# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RedisWebManager do
  # `redises`/`lifespan`/`authenticate` are module-level mattr_accessors shared
  # by the whole process. `configure` assigns them *before* it validates, so a
  # block that raises still leaves its (invalid) value behind — leaking into
  # later examples and other spec files. Snapshot and restore around each
  # example to keep the global config hermetic regardless of run order.
  around do |example|
    saved = [described_class.redises, described_class.lifespan, described_class.authenticate]
    example.run
    described_class.redises, described_class.lifespan, described_class.authenticate = *saved
  end

  describe 'Test default configuration' do
    it 'returns a Redis class' do
      expect(described_class.redises).to be_a(Hash)
    end

    it 'returns a nil class' do
      expect(described_class.authenticate).to be_nil
    end

    it 'returns a ActiveSupport::Duration class' do
      expect(described_class.lifespan).to be_a(ActiveSupport::Duration)
    end
  end

  describe 'Test configuration' do
    it 'returns a raise error (redises)' do
      expect do
        described_class.configure do |c|
          c.redises = 1
        end
      end.to raise_error(ArgumentError, 'Invalid redises hash, use like that { test: Redis.new }')
    end

    it 'returns a raise error (value of redises)' do
      expect do
        described_class.configure do |c|
          c.redises = {
            default: 1
          }
        end
      end.to raise_error(ArgumentError, 'Invalid Redis instance for default, use like that Redis.new')
    end

    it 'returns a raise error (invalid lifespan 1)' do
      expect do
        described_class.configure do |c|
          c.redises = {
            default: Redis.new
          }
          c.lifespan = 1
        end
      end.to raise_error(ArgumentError, 'Invalid lifespan, use like that 15.days, 15.minutes etc')
    end

    it 'returns a raise error (invalid lifespan 2)' do
      expect do
        described_class.configure do |c|
          c.redises = {
            default: Redis.new
          }
          c.lifespan = -1.days
        end
      end.to raise_error(ArgumentError, 'Invalid lifespan, value must be greater than 0')
    end

    it 'validates the current config when called without a block' do
      expect { described_class.configure }.not_to raise_error
    end

    it 'returns instances' do
      described_class.configure do |c|
        c.redises = {
          foo: Redis.new,
          bar: Redis.new
        }
        c.lifespan = 12.days
      end

      expect(described_class.redises.keys).to eql(%i[foo bar])
      expect(described_class.redises.values.map(&:class)).to eql([Redis, Redis])
    end
  end
end
