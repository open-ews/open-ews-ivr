module OpenEWS
  module ResponseParser
    class CollectionParser
      attr_reader :resource_response_parser

      def initialize(resource_response_parser)
        @resource_response_parser = resource_response_parser
      end

      class Parser
        attr_reader :payload, :resource_response_parser

        def initialize(payload, **options)
          @payload = payload
          @resource_response_parser = options.fetch(:resource_response_parser)
        end

        def call
          resources = data.map do |resource|
            resource_response_parser.parse("data" => resource, "included" => included)
          end
          OpenEWS::Resource::Collection.new(resources:)
        end

        private

        def params
          @params ||= JSON.parse(payload)
        end

        def data
          params.fetch("data")
        end

        def included
          params.fetch("included", [])
        end
      end

      def parse(payload, **options)
        Parser.new(payload, resource_response_parser:, **options).call
      end
    end
  end
end
