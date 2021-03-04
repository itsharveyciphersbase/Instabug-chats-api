module RedisCache
  class << self
    def redis
      @redis ||= Redis.new(:url => (ENV["REDIS_URL"] || 'http://127.0.0.1:6379'))
    end

    def method_missing(m, *args)
      redis.public_send(m, *args)
    end
  end
end