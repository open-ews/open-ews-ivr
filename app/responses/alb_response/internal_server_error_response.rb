require_relative "response"

module ALBResponse
  InternalServerErrorResponse = Response.new(
    status_code: 500,
    status_description: "500 Internal Server Error",
    is_base64_encoded: false,
    body: "Internal Server Error",
    headers: {
      "Content-Type": "text/plain"
    }
  )
end
