require "json"

module Gcpc
  module Interceptors
    module Subscriber
      # `DecodeInterceptor` decodes the message according to the strategy and
      # sets it in the attributes.
      class DecodeInterceptor < Gcpc::Subscriber::BaseInterceptor
        class BaseStrategy
          def decode(data, attributes, message)
            raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
          end
        end

        class JSONStrategy < BaseStrategy
          def decode(data, attributes, message)
            JSON.parse(data)
          end
        end

        # @param [BaseStrategy] strategy
        def initialize(strategy:)
          @strategy = strategy
        end

        # @param [String] data
        # @param [Hash] attributes
        # @param [Google::Cloud::Pubsub::ReceivedMessage] message
        # @param [Proc] block
        def handle(data, attributes, message, &block)
          m = @strategy.decode(data, attributes, message)
          yield m, attributes, message
        end
      end
    end
  end
end
