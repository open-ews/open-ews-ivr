require_relative "../spec_helper"

RSpec.describe "Handle ALB Events" do
  it "handles switch events" do
    payload = build_alb_event_payload

    invoke_lambda(payload:)
  end
end
