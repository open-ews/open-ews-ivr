class RequestParser
  class Parser
    attr_reader :payload

    Request = Data.define(:http_method, :path, :query_parameters, :headers, :body)

    def initialize(payload)
      @payload = payload
    end

    def call
      Request.new(
        http_method: payload.fetch("httpMethod"),
        path: payload.fetch("path"),
        query_parameters: payload.dig("queryStringParameters", "query"),
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
