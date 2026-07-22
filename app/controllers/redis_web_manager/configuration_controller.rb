# frozen_string_literal: true

module RedisWebManager
  class ConfigurationController < ApplicationController
    # CONFIG GET * returns secrets (requirepass, masterauth, ...) in cleartext;
    # never render them verbatim.
    SENSITIVE_CONFIG = /(pass|auth|secret)/i

    # GET /configuration
    def index
      @configurations = redact(info.configuration)
      @status = info.status
      @url = connection.id
    end

    private

    def redact(configuration)
      configuration.to_h do |key, value|
        masked = SENSITIVE_CONFIG.match?(key.to_s) && value.to_s != ''
        [key, masked ? '********' : value]
      end
    end
  end
end
