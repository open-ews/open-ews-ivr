require "jsonapi_response_parser"

module OpenEWS
  module ResponseParser
    class Base
      class Parser
        attr_reader :payload, :jsonapi_response_parser

        def initialize(payload:, **options)
          @payload = payload
          @jsonapi_response_parser = options.fetch(:jsonapi_response_parser) { JSONAPIResponseParser.new }
        end

        def call
          jsonapi_response_parser.parse(payload)
        end
      end

      def parse(...)
        Parser.new(...).call
      end
    end
  end
end
