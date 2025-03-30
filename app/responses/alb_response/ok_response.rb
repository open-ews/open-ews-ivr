require_relative "response"

module ALBResponse
  class OKResponse < Response
    def initialize(body: "OK", content_type: "text/plain", **headers)
      super(
        status_code: 200,
        status_description: "200 OK",
        is_base64_encoded: true,
        body: Base64.strict_encode64(body),
        headers: {
          "Content-Type" => content_type,
          **headers
        }
      )
    end
  end
end
