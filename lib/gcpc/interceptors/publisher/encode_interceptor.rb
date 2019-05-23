require "gcpc"

module Gcpc
  module Interceptors
    class Publisher
      # `EncodeInterceptor` encodes a data and publish it as a String.
      class EncodeInterceptor < Gcpc::Publisher::BaseInterceptor
        VALID_CONTENT_TYPES = [
          "json",
          "protobuf",
        ]

        def initialize(content_type:)
          @content_type = content_type.to_s
          validate!
        end

        # @param [#to_json, #to_proto] data
        # @param [Hash] attributes
        def publish(data, attributes)
          d = encode(data)
          a = attributes.merge("content_type" => @content_type)
          yield d, a
        end

      private

        def validate!
          if !VALID_CONTENT_TYPES.include?(@content_type)
            raise "invalid content_type: #{@content_type}"
          end
        end

        # @param [#to_json, #to_proto] data
        # @return [String]
        def encode(data)
          case @content_type
          when "json"
            data.to_json
          when "protobuf"
            data.to_proto
          else
            raise "invalid content_type: \"#{@content_type}\""
          end
        end
      end
    end
  end
end
