require "json"

module EventHelpers
  def build_alb_event_payload(data = {})
    payload = JSON.parse(file_fixture("alb_request_event.json").read)
    headers = payload.fetch("headers").merge(data.delete(:headers) || {})

    data = {
      http_method: :post,
      path: "/",
      body: "",
      query_parameters: {},
      is_base64_encoded: false,
      headers:
    }.merge(data)

    overrides = {
      "httpMethod" => data.fetch(:http_method).to_s.upcase,
      "path" => data.fetch(:path),
      "queryStringParameters" => data.fetch(:query_parameters),
      "headers" => data.fetch(:headers),
      "body" => data.fetch(:body),
      "isBase64Encoded" => data.fetch(:is_base64_encoded)
    }

    payload.merge(overrides)
  end
end

RSpec.configure do |config|
  config.include(EventHelpers)
end
