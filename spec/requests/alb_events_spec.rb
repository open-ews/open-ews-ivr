require_relative "../spec_helper"

RSpec.describe "Handle ALB Events" do
  it "handles 404s" do
    payload = build_alb_event_payload(path: "/")

    response = invoke_lambda(payload:)

    expect(response).to include(statusCode: 404)
  end

  it "handles unknown flows" do
    payload = build_alb_event_payload(path: "/ivr_flows/unknown")

    response = invoke_lambda(payload:)

    expect(response).to include(statusCode: 404)
  end

  it "handles valid ivr flows" do
    payload = build_alb_event_payload(path: "/ivr_flows/ews_1294_cambodia")

    response = invoke_lambda(payload:)

    expect(response).to include(
      statusCode: 200,
      headers: {
        "Content-Type" => "application/xml"
      },
      body: Base64.strict_encode64("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n<Play>https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/introduction-khm.wav</Play>\n<Redirect>/ivr_flows/ews_1294_cambodia?status=played_introduction</Redirect>\n</Response>\n")
    )
  end
end
