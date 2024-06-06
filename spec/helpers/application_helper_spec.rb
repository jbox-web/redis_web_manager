# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RedisWebManager::ApplicationHelper, type: :helper do
  describe 'helper' do
    it 'returns status tag (true)' do
      expect(helper.status(true)).to match(/ON/)
    end

    it 'returns status tag (true)' do
      expect(helper.status(false)).to match(/OFF/)
    end

    it 'returns url tag' do
      expect(helper.url('test.com')).to match(/kbd/)
    end

    it 'returns a no expiration' do
      expect(helper.expiry(-1)).to eql('No expiration date')
    end

    it 'returns a expiration' do
      expect(helper.expiry(86_400)).to eql('1 day')
    end
  end
end
