require_relative "ews_1294_cambodia_flow"
require_relative "ews_1393_laos_flow"

module IVRFlow
  class Collection
    class FlowNotFoundError < Errors::NotFoundError; end

    Flow = Data.define(:identifier, :handler)

    FLOWS = [
      Flow.new(identifier: "ews_1294_cambodia", handler: EWS1294CambodiaFlow),
      Flow.new(identifier: "ews_1393_laos", handler: EWS1393LaosFlow)
    ]

    def self.find(identifier)
      FLOWS.find(-> { raise Errors::NotFoundError }) do
        _1.identifier == identifier
      end
    end
  end
end
