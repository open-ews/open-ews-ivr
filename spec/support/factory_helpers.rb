module FactoryHelpers
  def build_request(**params)
    headers = params.fetch(:headers, { "host" => "ivr.open-ews.org", "x-forwarded-proto" => "https" })
    path = params.fetch(:path, "/")
    scheme = headers.fetch("x-forwarded-proto")
    host = headers.fetch("host")
    base_url = "#{scheme}://#{host}"
    query_parameters = params.fetch(:query_parameters, {})
    query_string = URI.encode_www_form(query_parameters)
    fullpath = query_string.empty? ? path : "#{path}?#{query_string}"
    url = base_url + fullpath

    Request.new(
      http_method: :post,
      path:,
      query_parameters:,
      headers:,
      host:,
      scheme:,
      body: "",
      port: 443,
      url:,
      **params
    )
  end

  def build_twilio_request(twilio: {}, **params)
    twilio_params = {
      from: "+855715100989",
      to: "1294",
      digits: nil,
      **twilio.fetch(:params, {})
    }

    request_validator = twilio.fetch(:request_validator) { TwilioRequestValidator.new }
    url = twilio.fetch(:url, "https://ivr.open-ews.org/ivr_flows/ews_1294_cambodia?status=introduction_played")
    payload = twilio.fetch(:payload) { twilio_params.compact.transform_keys { _1.to_s.camelize } }
    auth_token = twilio.fetch(:auth_token) { SecureRandom.alphanumeric(43) }
    signature = twilio.fetch(:signature) { request_validator.build_signature_for(auth_token:, url:, params: twilio_params) }

    twilio = TwilioRequest::Twilio.new(payload:, signature:, **twilio_params)
    request = build_request(**params)

    TwilioRequest.new(request, twilio)
  end
end

RSpec.configure do |config|
  config.include(FactoryHelpers)
end
