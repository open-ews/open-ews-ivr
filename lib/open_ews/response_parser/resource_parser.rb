module OpenEWS
  module ResponseParser
    class ResourceParser
      Resource = Data.define(:id, :type, :attributes, :relationships)

      class Parser
        attr_reader :payload

        def initialize(payload)
          @payload = payload
        end

        def call
          return payload if payload.is_a?(Resource)

          Resource.new(
            id:,
            type:,
            attributes:,
            relationships:
          )
        end

        private

        def relationships
          @relationships ||= data.fetch("relationships", {}).each_with_object(Hash.new { |h, k| h[k] = Array.new }) do |(name, relationship_payload), result|
            result[name] = []
            relationship_payload.fetch("data", []).each do |relationship_data|
              relationship_attributes = included.find(-> { {} }) do
                _1.fetch("id") == relationship_data.fetch("id") && _1.fetch("type") == relationship_data.fetch("type")
              end

              result[name] << Resource.new(
                id: relationship_data.fetch("id"),
                type: relationship_data.fetch("type"),
                attributes: relationship_attributes.fetch("attributes", {}),
                relationships: nil
              )
            end
          end
        end

        def params
          @params ||= payload.is_a?(Hash) ? payload : JSON.parse(payload)
        end

        def data
          params.fetch("data")
        end

        def included
          params.fetch("included", [])
        end

        def attributes
          data.fetch("attributes")
        end

        def id
          data.fetch("id")
        end

        def type
          data.fetch("type")
        end
      end

      def parse(...)
        Parser.new(...).call
      end
    end
  end
end
