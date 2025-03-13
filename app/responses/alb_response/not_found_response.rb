require_relative "response"

module ALBResponse
  NotFoundResponse = Response.new(
    status_code: 404,
    status_description: "404 Not Found",
    is_base64_encoded: false,
    body: "Not Found",
    headers: {
      "Content-Type": "text/plain"
    }
  )
end
