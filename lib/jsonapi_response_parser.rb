require "json"

class JSONAPIResponseParser
  Response = Data.define(:id, :attributes)

  class Parser
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    def call
      Response.new(
        id:,
        attributes:
      )
    end

    private

    def params
      @params ||= JSON.parse(payload)
    end

    def data
      params.fetch("data")
    end

    def attributes
      data.fetch("attributes")
    end

    def id
      data.fetch("id")
    end
  end

  def parse(...)
    Parser.new(...).call
  end
end
