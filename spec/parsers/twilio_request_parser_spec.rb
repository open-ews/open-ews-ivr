require "spec_helper"

RSpec.describe TwilioRequestParser do
  it "parses twilio requests" do
    request = build_request(
      body: URI.encode_www_form(
        "From" => "+855716599333",
        "To" => "1294",
        "Direction" => "inbound",
        "Digits" => "*"
      ),
      headers: {
        "x-twilio-signature" => "signature"
      }
    )
    request_parser = TwilioRequestParser.new

    request = request_parser.parse(request)

    expect(request.twilio).to have_attributes(
      from: "+855716599333",
      to: "1294",
      direction: "inbound",
      beneficiary: "+855716599333",
      digits: "*",
      signature: "signature"
    )
  end

  it "handles outbound calls" do
    request = build_request(
      body: URI.encode_www_form(
        "From" => "1294",
        "To" => "+855716599333",
        "Direction" => "outbound-api",
      ),
      headers: {
        "x-twilio-signature" => "signature"
      }
    )
    request_parser = TwilioRequestParser.new

    request = request_parser.parse(request)

    expect(request.twilio).to have_attributes(
      from: "1294",
      to: "+855716599333",
      direction: "outbound-api",
      beneficiary: "+855716599333",
      digits: nil
    )
  end
end
