module FactoryHelpers
  def build_request(**params)
    Request.new(
      http_method: :post,
      path: "/",
      query_parameters: {},
      headers: {},
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
