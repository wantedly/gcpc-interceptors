require "date"

module Gcpc
  module Interceptors
    module Subscriber
      # `CheckOrderInterceptor` checks the order of messages in each group.
      class CheckOrderInterceptor < Gcpc::Subscriber::BaseInterceptor
        class BaseStrategy
          DEFAULT_TIMESTAMP_KEY = "published_at"
          DEFAULT_TTL           = 7 * 24 * 3600  # 7 days

          def initialize(ttl: DEFAULT_TTL, timestamp_key: DEFAULT_TIMESTAMP_KEY)
            @ttl           = ttl
            @timestamp_key = DEFAULT_TIMESTAMP_KEY
          end

          attr_reader :ttl

          # @param [String] data
          # @param [Hash] attributes
          # @param [Google::Cloud::Pubsub::ReceivedMessage] message
          # @return [String, nil]
          def timestamp(data, attributes, message)
            attributes[@timestamp_key]
          end

          # @param [String] str
          # @return [DateTime, nil]
          def decode_timestamp(str)
            DateTime.parse(str)
          rescue ArgumentError, TypeError
            nil
          end

          # @param [String] data
          # @param [Hash] attributes
          # @param [Google::Cloud::Pubsub::ReceivedMessage] message
          # @return [String]
          def group_id(data, attributes, message)
            # The default behavior is to always return the same key. This means
            # that all messages should be in order. If you want to change the
            # set of messages you want to order, please override this method.
            "same-id"
          end

          # @param [String] data
          # @param [Hash] attributes
          # @param [Google::Cloud::Pubsub::ReceivedMessage] message
          # @param [Proc] block
          def on_swapped(data, attributes, message, &block)
            # By default, simply yield
            yield data, attributes, message
          end
        end

        # @param [#get, #set] store
        # @param [Logger] logger
        # @param [BaseStrategy] strategy
        def initialize(store:, logger: Logger.new(STDOUT), strategy: BaseStrategy.new)
          @store    = store
          @logger   = logger
          @strategy = strategy
        end

        # @param [String] data
        # @param [Hash] attributes
        # @param [Google::Cloud::Pubsub::ReceivedMessage] message
        # @param [Proc] block
        def handle(data, attributes, message, &block)
          timestamp = @strategy.timestamp(data, attributes, message)

          if timestamp.nil?
            yield data, attributes, message
            return
          end

          group_id = @strategy.group_id(data, attributes, message)
          if swapped?(group_id, timestamp)
            @strategy.on_swapped(data, attributes, message, &block)
            return
          end

          yield data, attributes, message
        end

      private

        # @param [String] group_id
        # @param [String] timestamp represents the published timestamp in
        # RFC3339 format.
        def swapped?(group_id, message_timestamp)
          message_t = @strategy.decode_timestamp(message_timestamp)
          return false if message_t.nil?  # Decode error occured

          k = key(group_id)

          stored_timestamp = @store.get(k)
          if stored_timestamp.nil?  # stored_timestamp does not exist in store
            set(k, message_timestamp)
            return false
          end

          stored_t = @strategy.decode_timestamp(stored_timestamp)
          if stored_t.nil?  # Decode error occured
            @logger.error("Failed to decode a stored timestamp! The stored value is \"#{stored_timestamp}\"!")
            set(k, message_timestamp)

            # Since it is not possible to confirm the occurrence of swap,
            # we treat decode errors as swap.
            return true
          end

          # The message's timestamp should be larger than stored timestamp
          # (last message's timestamp). If not, the order of messages are
          # swapped.
          r = message_t < stored_t
          if !r
            # Store the closest timestamp
            set(k, message_timestamp)
          end
          r
        end

        def key(group_id)
          "CheckOrderInterceptor:key:#{group_id}"
        end

        def set(key, timestamp)
          @store.set(key, timestamp, ttl: @strategy.ttl)
        end
      end
    end
  end
end
