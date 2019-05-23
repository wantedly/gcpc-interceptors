module Gcpc
  module Interceptors
    module Utils
      class RedisStore
        def initialize(redis:)
          @redis = redis
        end

        # @param [String] key
        # @return [String]
        def get(key)
          @redis.get(key)
        end

        # @param [String] key
        # @param [String] val
        # @param [String] val
        # @return [String, bool]
        def set(key, val, ttl: nil)
          if ttl
            @redis.setex(key, ttl, val)
          else
            @redis.set(key, val)
          end
        end

        # @param [String] key
        # @return [bool]
        def exists(key)
          @redis.exists(key)
        end
      end
    end
  end
end
