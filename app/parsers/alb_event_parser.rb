class ALBEventParser
  Event = Data.define(:http_method, :path, :query_parameters, :headers, :body, :is_base64_encoded)

  def parse(payload)
    Event.new(
      http_method: payload.fetch("httpMethod"),
      path: payload.fetch("path"),
      query_parameters: payload.dig("queryStringParameters", "query"),
      headers: payload.fetch("headers"),
      body: payload.fetch("body"),
      is_base64_encoded: payload.fetch("isBase64Encoded")
    )
  end
end
