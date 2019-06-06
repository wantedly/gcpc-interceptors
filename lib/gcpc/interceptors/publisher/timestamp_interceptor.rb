require "date"

module Gcpc
  module Interceptors
    module Publisher
      # `TimestampInterceptor` adds a timestamp to a message's attributes in
      # RFC3339 format.
      class TimestampInterceptor < Gcpc::Publisher::BaseInterceptor
        DEFAULT_TIMESTAMP_KEY = "published_at"

        def initialize(timestamp_key: DEFAULT_TIMESTAMP_KEY)
          @timestamp_key = timestamp_key
        end

        # @param [String] data
        # @param [Hash] attributes
        def publish(data, attributes)
          a = attributes.merge(@timestamp_key => DateTime.now.rfc3339)
          yield data, a
        end
      end
    end
  end
end
