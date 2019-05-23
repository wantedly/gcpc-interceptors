require "gcpc"

module Gcpc
  module Interceptors
    class Subscriber
      # `CheckOrderInterceptor` checks the duplication of messages.
      class CheckDupInterceptor < Gcpc::Subscriber::BaseInterceptor
        class BaseStrategy
          DEFAULT_ID_KEY = "message_id"
          DEFAULT_TTL    = 7 * 24 * 3600  # 7 days

          def initialize(ttl: DEFAULT_TTL, id_key: DEFAULT_ID_KEY)
            @ttl    = ttl
            @id_key = id_key
          end

          attr_reader :ttl

          def id(data, attributes, message)
            attributes[@id_key]
          end

          def on_dup(data, attributes, message, &block)
            # Do nothing. Just ignore the duplicated message.
          end
        end

        # @param [#exists, #set] store
        # @param [BaseStrategy] strategy
        def initialize(store:, strategy: BaseStrategy.new)
          @store    = store
          @strategy = strategy
        end

        # @param [String] data
        # @param [Hash] attributes
        # @param [Google::Cloud::Pubsub::ReceivedMessage] message
        # @param [Proc] block
        def handle(data, attributes, message, &block)
          id = @strategy.id(data, attributes, message)

          if !id.nil? && duplicated?(id)
            @strategy.on_dup(data, attributes, message, &block)
            return
          end

          yield data, attributes, message
        end

      private

        # @param [String] id
        # @param [bool] true if id is already stored on `store`.
        def duplicated?(id)
          k = key(id)
          r = @store.exists(k)
          @store.set(k, "exists", ttl: @strategy.ttl) if !r
          r
        end

        def key(id)
          "CheckDupInterceptor:key:#{id}"
        end
      end
    end
  end
end
