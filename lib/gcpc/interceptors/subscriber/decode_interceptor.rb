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
        # @param [Logger] logger
        # @param [Boolean] ignore_on_error Ignore the message when decode failed
        def initialize(strategy:, logger: Logger.new(STDOUT), ignore_on_error: true)
          @strategy        = strategy
          @logger          = logger
          @ignore_on_error = ignore_on_error
        end

        # @param [String] data
        # @param [Hash] attributes
        # @param [Google::Cloud::Pubsub::ReceivedMessage] message
        # @param [Proc] block
        def handle(data, attributes, message, &block)
          begin
            m = @strategy.decode(data, attributes, message)
          rescue => e
            @logger.error(e)

            if @ignore_on_error
              @logger.info("Ack a message{data=#{message.data}, attributes=#{message.attributes}} because it can't be decoded!")
              message.ack!  # Ack immediately if decode failed
              return
            else
              raise e
            end
          end

          yield m, attributes, message
        end
      end
    end
  end
end
