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

  it "handles EWS 1294 Cambodia flows" do
    uri = URI("https://ivr.open-ews.org/ivr_flows/ews_1294_cambodia?status=commune_prompted&language=cmo&province=11&district=1102")
    twilio_params = {
      "From" => "+855716599333",
      "To" => "1294",
      "Digits" => "2"
    }
    payload = build_alb_event_payload(
      path: uri.path,
      query_parameters: URI.decode_www_form(uri.query).to_h,
      body: URI.encode_www_form(twilio_params),
      headers: {
        "host" => uri.host,
        "x-forwarded-proto" => uri.scheme,
        "x-twilio-signature" => build_twilio_signature(auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b", url: uri.to_s, params: twilio_params)
      }
    )
    stub_request(:get, "https://api.open-ews.org/v1/account").to_return(
      body: JSON.dump(
        {
          data: {
            id: "1",
            type: "account",
            attributes: {
              somleng_account_sid: SecureRandom.uuid,
              somleng_auth_token: "6GmFR2ny48GrmlIldBTg9fG4OC6lI5W5Pn70YkADD1b"
            }
          }
        }
      )
    )
    stub_request(:get, %r{https://api.open-ews.org/v1/beneficiaries}).to_return(
      body: JSON.dump(
        {
          data: [
            {
              id: "1",
              type: "beneficiary",
              attributes: {
                phone_number: "855972346004"
              },
              relationships: {
                addresses: {
                  data: [
                    {
                      id: "1",
                      type: "address"
                    }
                  ]
                }
              }
            }
          ],
          included: [
            {
              id: "1",
              type: "address",
              attributes: {
                iso_region_code: "KH-4",
                administrative_division_level_2_code: "0401",
                administrative_division_level_2_name: "Baribour",
                administrative_division_level_3_code: "040106",
                administrative_division_level_3_name: "Melum"
              }
            }
          ]
        }
      )
    )

    response = invoke_lambda(payload:)

    expect(response).to include(
      statusCode: 200,
      headers: {
        "Content-Type" => "application/xml"
      },
      body: Base64.strict_encode64("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n<Play>https://s3.ap-southeast-1.amazonaws.com/audio.open-ews.org/ews_registration/registration_successful-cmo.wav</Play>\n<Hangup/>\n</Response>\n")
    )
  end
end
