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
    payload = build_alb_event_payload(path: "/ivr_flows/ews_1294_registration")

    response = invoke_lambda(payload:)

    binding.pry
  end
end
