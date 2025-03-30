class RequestParser
  class Parser
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    # See: https://github.com/aws-samples/rails-lambda-handler/blob/2bc5125f169dd814f0afc08307eee40c0f0caf40/rails/lambda_rest.rb#L31
    # https://github.com/rack/rack/blob/962d7db82be1a16ee38953560715d4af989e984f/lib/rack/request.rb#L572

    def call
      Request.new(
        http_method:, path:, query_parameters:, headers:, body:, host:, port:, scheme:, url:
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

    def http_method
      payload.fetch("httpMethod").downcase.to_sym
    end

    def port
      headers.fetch("x-forwarded-port")
    end

    def path
      payload.fetch("path")
    end

    def base_url
      "#{scheme}://#{host}"
    end

    def scheme
      headers.fetch("cloudfront-forwarded-proto") { headers.fetch("x-forwarded-proto") }
    end

    def fullpath
      query_string.empty? ? path : "#{path}?#{query_string}"
    end

    def host
      headers.fetch("x-forwarded-host") { headers.fetch("host") }
    end

    def query_parameters
      payload.fetch("queryStringParameters")
    end

    def query_string
      URI.encode_www_form(query_parameters)
    end

    # Tries to return a remake of the original request URL as a string.
    def url
      base_url + fullpath
    end
  end

  def parse(...)
    Parser.new(...).call
  end
end
