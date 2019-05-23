require "gcpc"

module Gcpc
  module Interceptors
    class Publisher
      # `PublisherNameInterceptor` adds a publisher name to a message's
      # attributes
      class PublisherNameInterceptor < Gcpc::Publisher::BaseInterceptor
        # @param [String] publisher
        def initialize(publisher:)
          @publisher = publisher
        end

        # @param [String] data
        # @param [Hash] attributes
        def publish(data, attributes)
          a = attributes.merge("published_by" => @publisher)
          yield data, a
        end
      end
    end
  end
end
