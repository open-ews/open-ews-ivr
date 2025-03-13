require_relative "ews_1294_registration_flow"

module IVRFlow
  class Collection
    class FlowNotFoundError < Errors::NotFoundError; end

    Flow = Data.define(:identifier, :handler)

    FLOWS = [
      Flow.new(identifier: "ews_1294_registration", handler: EWS1294RegistrationFlow)
    ]

    def self.find(identifier)
      FLOWS.find(-> { raise Errors::NotFoundError }) do
        _1.identifier == identifier
      end
    end
  end
end
