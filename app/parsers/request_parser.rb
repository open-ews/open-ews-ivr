class RequestParser
  class Parser
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    def call
      Request.new(
        http_method: payload.fetch("httpMethod").downcase.to_sym,
        path: payload.fetch("path"),
        query_parameters: payload.fetch("queryStringParameters"),
        headers: payload.fetch("headers"),
        body:
      )
    end

    private

    def base64_encoded?
      payload.fetch("isBase64Encoded")
    end

    def body
      base64_encoded? ? Base64.decode64(payload.fetch("body")) : payload.fetch("body")
    end
  end

  def parse(...)
    Parser.new(...).call
  end
end
