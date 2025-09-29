require "spec_helper"

RSpec.describe "EWS 1393 Laos" do
  it "handles EWS 1393 Laos flows" do
    uri = URI("https://ivr.open-ews.org/ivr_flows/ews_1393_laos?province=16&status=district_prompted")
    twilio_params = {
      "From" => "+8562052477750",
      "To" => "1393",
      "Digits" => "1",
      "Direction" => "inbound"
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
                phone_number: "8562052477750",
                iso_country_code: "LA"
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
                iso_region_code: "LA-CH",
                administrative_division_level_2_code: "1602",
                administrative_division_level_2_name: "Sanasomboun",
                administrative_division_level_3_code: nil,
                administrative_division_level_3_name: nil,
                administrative_division_level_4_code: nil,
                administrative_division_level_4_name: nil
              }
            }
          ]
        }
      )
    )
    stub_request(:post, "https://api.open-ews.org/v1/beneficiaries/1/addresses").to_return(
      body: JSON.dump(
        {
          data: {
            id: "2",
            type: "address",
            attributes: {
              iso_region_code: "LA-CH",
              administrative_division_level_2_code: "1601",
              administrative_division_level_2_name: "Pakse",
              administrative_division_level_3_code: nil,
              administrative_division_level_3_name: nil,
              administrative_division_level_4_code: nil,
              administrative_division_level_4_name: nil
            }
          }
        }
      )
    )

    response = invoke_lambda(payload:)

    expect(response).to include(
      statusCode: 200,
      headers: {
        "Content-Type" => "application/xml"
      },
      body: Base64.strict_encode64("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n<Play>https://uploads.open-ews.org/ews_1393_laos/registration_successful-lao.mp3</Play>\n<Hangup/>\n</Response>\n")
    )
  end
end
