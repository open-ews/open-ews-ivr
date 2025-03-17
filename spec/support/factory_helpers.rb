module FactoryHelpers
  def build_request(**params)
    headers = params.fetch(:headers, { "host" => "ivr.open-ews.org", "x-forwarded-proto" => "https" })

    Request.new(
      http_method: :post,
      path: "/",
      query_parameters: {},
      headers:,
      host: headers.fetch("host"),
      protocol: headers.fetch("x-forwarded-proto"),
      body: "",
      **params
    )
  end

  def build_twilio_request(twilio_params: {}, **params)
    twilio = TwilioRequest::Twilio.new(
      from: "+855715100989",
      to: "1294",
      digits: nil,
      **twilio_params
    )
    request = build_request(**params)

    TwilioRequest.new(request, twilio)
  end
end

RSpec.configure do |config|
  config.include(FactoryHelpers)
end
