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
        headers:,
        body:,
        host: headers.fetch("host"),
        protocol: headers.fetch("x-forwarded-proto")
      )
    end

    private

    def base64_encoded?
      payload.fetch("isBase64Encoded")
    end

    def body
      base64_encoded? ? Base64.decode64(payload.fetch("body")) : payload.fetch("body")
    end

    def headers
      payload.fetch("headers")
    end
  end

  def parse(...)
    Parser.new(...).call
  end
end
