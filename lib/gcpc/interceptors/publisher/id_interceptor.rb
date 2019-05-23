require "securerandom"
require "gcpc"

module Gcpc
  module Interceptors
    class Publisher
      # `IdInterceptor` adds an unique id to a message's attributes
      class IdInterceptor < Gcpc::Publisher::BaseInterceptor
        DEFAULT_ID_KEY = "message_id"

        def initialize(id_key: DEFAULT_ID_KEY)
          @id_key = id_key
        end

        # @param [#to_json, #to_proto] data
        # @param [Hash] attributes
        def publish(data, attributes)
          a = attributes.merge(@id_key => id)
          yield data, a
        end

      private

        def id
          SecureRandom.uuid
        end
      end
    end
  end
end
