require_relative "response"

module ALBResponse
  class OKResponse < Response
    def initialize(body:, content_type:, **headers)
      super(
        status_code: 200,
        status_description: "200 OK",
        is_base64_encoded: true,
        body: Base64.urlsafe_encode64(body),
        headers: {
          "Content-Type" => content_type,
          **headers
        }
      )
    end
  end
end
