# frozen_string_literal: true

module RedisWebManager
  class Connection < Base
    attr_reader :host, :port, :db, :id, :location

    def initialize(instance)
      super
      @host     = fetch_attribute(:host)
      @port     = fetch_attribute(:port)
      @db       = fetch_attribute(:db)
      @id       = fetch_attribute(:id)
      @location = fetch_attribute(:location)
    end

    private

    def fetch_attribute(attribute)
      redis_connection[attribute]
    end
  end
end
