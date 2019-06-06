module Gcpc
  module Interceptors
    module Utils
      class RedisStore
        def initialize(redis:)
          @redis = redis
        end

        # @param [String] key
        # @return [String]
        # @raise Redis::BaseConnectionError
        def get(key)
          @redis.get(key)
        end

        # @param [String] key
        # @param [String] val
        # @param [Integer, nil] ttl
        # @return [bool]
        # @raise Redis::BaseConnectionError
        def set(key, val, ttl: nil)
          if ttl
            @redis.setex(key, ttl, val)
          else
            @redis.set(key, val)
          end
          true
        end

        # @param [String] key
        # @return [bool]
        # @raise Redis::BaseConnectionError
        def exists(key)
          @redis.exists(key)
        end
      end
    end
  end
end
